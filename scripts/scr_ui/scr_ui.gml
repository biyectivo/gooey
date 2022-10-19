#region Helper Enums and Macros
	#macro UI_NUM_CALLBACKS 14
	#macro UI_LIBRARY_NAME "UI2"
	enum UI_EVENT {
		MOUSE_OVER,
		LEFT_CLICK,
		MIDDLE_CLICK,
		RIGHT_CLICK,
		LEFT_HOLD,
		MIDDLE_HOLD,
		RIGHT_HOLD,
		LEFT_RELEASE,
		MIDDLE_RELEASE,
		RIGHT_RELEASE,
		MOUSE_ENTER,		
		MOUSE_EXIT,
		MOUSE_WHEEL_UP,
		MOUSE_WHEEL_DOWN
	}
	enum UI_TYPE {
		PANEL,
		BUTTON,
		GROUP
	}
	enum UI_RESIZE_DRAG {
		NONE,
		DRAG,
		RESIZE_NW,
		RESIZE_N,
		RESIZE_NE,
		RESIZE_W,
		RESIZE_E,
		RESIZE_SW,
		RESIZE_S,
		RESIZE_SE
	}
	enum UI_ANCHOR_H {
		LEFT,
		CENTER,
		RIGHT
	}
	enum UI_RELATIVE_TO {
		TOP_LEFT,
		TOP_CENTER,
		TOP_RIGHT,
		MIDDLE_LEFT,
		MIDDLE_CENTER,
		MIDDLE_RIGHT,
		BOTTOM_LEFT,
		BOTTOM_CENTER,
		BOTTOM_RIGHT
	}
	
#endregion

#region Helper Functions
	
#endregion

#region Widgets

	function UIPanel(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.PANEL;			
			self.__draggable = true;
			self.__drag_bar_height = 20;
			self.__resizable = true;			
			self.__resize_border_width = 10;
			self.__title = "";
			self.__title_horizontal_anchor = UI_ANCHOR_H.CENTER;
			self.__close_button = noone;
		#endregion
		#region Setters/Getters
			self.getDragDimensions = function()			{ return self.__drag_area_dimensions; }
			self.setDragDimensions = function(_x=undefined, _y=undefined, _width=undefined, _height=undefined)	{
				self.__drag_area_dimensions.x ??= _x;
				self.__drag_area_dimensions.y ??= _y;
				self.__drag_area_dimensions.width ??= _width;
				self.__drag_area_dimensions.height ??= _height;
			}
			self.getTitle = function()							{ return self.__title; }
			self.setTitle = function(_title)					{ self.__title = _title; }
			self.getTitleHorizontalAnchor = function()			{ return self.__title_horizontal_anchor; }
			self.setTitleHorizontalAnchor = function(_anchor)	{ self.__title_horizontal_anchor = _anchor; }
			self.getDragBarHeight = function()					{ return self.__drag_bar_height; }
			self.setDragBarHeight = function(_height)			{ self.__drag_bar_height = _height; }
			self.getCloseButton = function()					{ return self.__close_button; }
			self.setCloseButton = function(_button_id)	{
				var _id = self.__ID+"_close";
				if (_button_id == noone) {
					self.deleteChildren(_id);
				}
				else {
					self.__close_button = _button_id;
					self.__close_button.__ID = _id;
					add(self.__close_button);
					self.__close_button.setCallback(UI_EVENT.LEFT_CLICK, function() {
						self.cleanUp();						
					});
					self.updateChildrenPositions();
				}
			}
		#endregion
		#region Methods
			self.__draw = function(_absolute_coords = true) {
				var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
				var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);
				// Title
				if (self.__title != "")	{					
					var _s = scribble(self.__title);
					
					var _h = _s.get_height();
					var _title_x = self.__title_horizontal_anchor == UI_ANCHOR_H.LEFT ? _x : (self.__title_horizontal_anchor == UI_ANCHOR_H.CENTER ? _x+_width/2 : _x+_width);
					var _title_y = self.__drag_bar_height == self.__dimensions.height ? _y + _h/2 : _y + self.__drag_bar_height;
					_s.draw(_title_x, _title_y);
				}
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK])	obj_UI.setPanelFocus(self);				
			}
			self.__drag = function() {					
				if (self.__draggable && obj_UI.__drag_action == UI_RESIZE_DRAG.DRAG) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SE) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.updateChildrenPositions();					
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NE) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_N) {
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_S) {
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_W) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_E) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.updateChildrenPositions();
				}
			}
		#endregion

		self.register();
		
		self.setClipsContent(true);
		
		return self;
	}
	
	function UIButton(_id, _x, _y, _width, _height, _text, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.BUTTON;
			self.__text = _text;
			self.__sprite_mouseover = self.__sprite;
			self.__image_mouseover = 0;
			self.__text_mouseover = _text;
			self.__sprite_click = self.__sprite;
			self.__image_click = 0;
			self.__text_click = _text;
		#endregion
		#region Setters/Getters
			self.getText = function()							{ return self.__text; }
			self.setText = function(_text)						{ self.__text = _text; }
			self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; }
			self.getSpriteClick = function()					{ return self.__sprite_click; }
			self.setSpriteClick = function(_sprite)				{ self.__sprite_click = _sprite; }
			self.getImageMouseover = function()					{ return self.__image_mouseover; }
			self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; }
			self.getImageClick = function()						{ return self.__image_click; }
			self.setImageClick = function(_image)				{ self.__image_click = _image; }
			self.getTextMouseover = function()					{ return self.__text_mouseover; }
			self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; }
			self.getTextClick = function()						{ return self.__text_click; }
			self.setTextClick = function(_text_click)			{ self.__text_click = _text_click; }
		#endregion
		#region Methods
			self.__draw = function(_absolute_coords = true) {
				var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
				var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				
				var _sprite = self.__sprite;
				var _image = self.__image;
				var _text = self.__text;
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_sprite =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__sprite_click : self.__sprite_mouseover;
					_image =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__image_click : self.__image_mouseover;
					_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
				}
				draw_sprite_stretched(_sprite, _image, _x, _y, _width, _height);
								
				var _x = _x + self.__dimensions.width * obj_UI.getScale()/2;
				var _y = _y + self.__dimensions.height * obj_UI.getScale()/2;
				var _scale = "[scale,"+string(obj_UI.getScale())+"]";
				
				scribble(_scale+_text).draw(_x, _y);
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
			}
		#endregion
		
		self.register();
		return self;
	}
	
	function UIGroup(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.GROUP;	
		#endregion
		#region Setters/Getters
			
		#endregion
		#region Methods
			self.__draw = function(_absolute_coords = true) {
				var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
				var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);				
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
			}
		#endregion
		
		self.register();
		return self;
	}

#endregion

#region Helper Structs
	function None() {}
	
	/*
		__UIDimensions constructor:
				
		_relative_to	Corner of widget that will be set, relative to corresponding corner of parent. If no parent, assume screen.
		_offset_x		Amount of horizontal pixels to move, starting from the _relative_to corner, to set the x position. Can be negative as well.
						This is NOT the x position of the top left corner (except if _relative_to is TOP_LEFT), but rather the x position of the corresponding corner.
		_offset_y		Amount of vertical pixels to move, starting from the _relative_to corner, to set the y position. Can be negative as well.
						This is NOT the y position of the top corner (except if _relative_to is TOP_LEFT), but rather the y position of the corresponding corner.
		_width			Width of widget
		_height			Height of widget
		
		Apart from those, two sets of coordinates are created:
		
		x				x coordinate of the TOP_LEFT corner of the widget, relative to SCREEN (absolute coordinates). These will be used to draw the widget on screen and perform the event handling checks.
		y				y coordinate of the TOP_LEFT corner of the widget, relative to SCREEN (absolute coordinates). These will be used to draw the widget on screen and perform the event handling checks.
		x_parent		x coordinate of the TOP_LEFT corner of the widget, relative to PARENT (relative coordinates). These will be used to draw the widget inside other widgets which have the clipContents property enabled (e.g. scrollable panels or other scrollable areas).
		y_parent		y coordinate of the TOP_LEFT corner of the widget, relative to PARENT (relative coordinates). These will be used to draw the widget inside other widgets which have the clipContents property enabled (e.g. scrollable panels or other scrollable areas).
		
	*/
	
	
	function __UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _id) constructor {
		if (live_call()) return live_result;
		self.widget_id = _id;
		self.relative_to = _relative_to;
		self.offset_x = _offset_x;
		self.offset_y = _offset_y;
		self.width = _width;
		self.height = _height;
		self.parent = noone;
		
		// These values are ALWAYS the coordinates of the top-left corner, irrespective of the relative_to value
		self.x = 0;
		self.y = 0;
		self.relative_x = 0;
		self.relative_y = 0;
		
		self.calculateCoordinates = function() {			
			if (live_call()) return live_result;
			// Get parent x,y SCREEN TOP-LEFT coordinates and width,height (if no parent, use GUI size)
			var _parent_x = 0;
			var _parent_y = 0;
			var _parent_w = display_get_gui_width();
			var _parent_h = display_get_gui_height();
			if (self.parent != noone) {
				_parent_x = self.parent.__dimensions.x;
				_parent_y = self.parent.__dimensions.y;
				_parent_w = self.parent.__dimensions.width;
				_parent_h = self.parent.__dimensions.height;
			}
			// Calculate the starting point
			var _starting_point_x = _parent_x;
			var _starting_point_y = _parent_y;
			if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
				_starting_point_x += _parent_w/2;
			}
			else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
				_starting_point_x += _parent_w;
			}
			if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
				_starting_point_y += _parent_h/2;
			}
			else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
				_starting_point_y += _parent_h;
			}
			// Calculate anchor point
			var _anchor_point_x = _starting_point_x + self.offset_x;
			var _anchor_point_y = _starting_point_y + self.offset_y;
			// Calculate widget TOP_LEFT SCREEN x,y coordinates (absolute)
			self.x = _anchor_point_x;
			self.y = _anchor_point_y;
			if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
				self.x -= self.width/2;
			}
			else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
				self.x -= self.width;
			}
			if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
				self.y -= self.height/2;
			}
			else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
				self.y -= self.height;
			}
			// Calculate widget RELATIVE x,y coordinates (relative to parent)
			self.relative_x = self.x - _parent_x;
			self.relative_y = self.y - _parent_y;
			/*
			show_debug_message(	string(self.widget_id.__ID) +" > Anchor: "+string(self.relative_to)+" / "+
								"Specified: "+string(self.offset_x)+","+string(self.offset_y)+" / "+
								"Absolute: "+string(self.x)+","+string(self.y)+" / "+
								"Relative: "+string(self.relative_x)+","+string(self.relative_y)
			);
			*/
		}
		
		self.setParent = function(_parent) {
			self.parent = _parent;
			// Update screen and relative coordinates with new parent
			self.calculateCoordinates();
		}
		
		self.set = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to=undefined) {
			self.offset_x ??= _offset_x;
			self.offset_y ??= _offset_y;
			self.relative_to ??= _relative_to;
			self.width ??= _width;
			self.height ??= _height;
			// Update screen and relative coordinates with new parent
			self.calculateCoordinates();
		}
		
		// Set parent (and calculate screen/relative coordinates) on creation
		self.setParent(_parent);
	}	
	
	function __UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) constructor {
		#region Private variables
			self.__ID = _id;
			self.__type = -1;
			self.__dimensions = new __UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to, noone, self);
			self.__sprite = _sprite;
			self.__image = 0;
			self.__events_fired_last = array_create(UI_NUM_CALLBACKS, false);
			self.__events_fired = array_create(UI_NUM_CALLBACKS, false);
			self.__callbacks = array_create(UI_NUM_CALLBACKS, None);
			self.__parent = noone;
			self.__children = [];
			self.__builtInBehavior = None;			
			self.__visible = true;
			self.__enabled = true;
			self.__draggable = false;			
			self.__resizable = false;
			self.__resize_border_width = 0;
			self.__drag_bar_height = self.__dimensions.height;
			self.__clips_content = false;
			self.__surface_id = noone;
			self.__min_width = 1;
			self.__min_height = 1;
		#endregion
		#region Setters/Getters
			static getID = function()					{ return self.__ID; }
			static getType = function()					{ return self.__type; }			
			static getDimensions = function()			{ return self.__dimensions; }
			static setDimensions = function(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone)	{
				self.__dimensions.set(_offset_x, _offset_y, _width, _height, _relative_to, _parent);
			}
			static getSprite = function()				{ return self.__sprite; }
			static setSprite = function(_sprite)		{ self.__sprite = _sprite; }
			static getCallback = function(_callback_type)				{ return self.__callbacks[_callback_type]; }
			static setCallback = function(_callback_type, _function)	{ self.__callbacks[_callback_type] = _function; }
			static getParent = function()				{ return self.__parent; }
			static setParent = function(_parent_id)		{ 
				self.__parent = _parent_id;
				self.__dimensions.setParent(_parent_id);
			}
			static getChildren = function()				{ return self.__children; }
			static setChildren = function(_children)	{ self.__children = _children; }
			static getVisible = function()				{ return self.__visible; }
			static setVisible = function(_visible)		{ self.__visible = _visible; }
			static getEnabled = function()				{ return self.__enabled; }
			static setEnabled = function(_enabled)		{ self.__enabled = _enabled; }
			static getDraggable = function()			{ return self.__draggable; }
			static setDraggable = function(_draggable)	{ self.__draggable = _draggable; }
			static getResizable = function()			{ return self.__resizable; }
			static setResizable = function(_resizable)	{ self.__resizable = _resizable; }
			static getResizeBorderWidth = function()		{ return self.__resize_border_width; }
			static setResizeBorderWidth = function(_border_width)		{ self.__resize_border_width = _border_width; }
			static getImage = function()				{ return self.__image; }
			static setImage = function(_image)			{ self.__image = _image; }
			static add = function(_id) {
				_id.__parent = self;
				_id.__dimensions.setParent(self);
				array_push(self.__children, _id);
				return _id;
			}
			static getClipsContent = function()			{ return self.__clips_content; }
			static setClipsContent = function(_clips) {
				self.__clips_content = _clips;
				if (_clips) {
					if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
				}
				else {
					if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
					self.__surface_id = noone;
				}
			}			
		#endregion
		#region Methods
			static register = function() {
				obj_UI.register(self);
			}
			static updateChildrenPositions = function() {
				for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
					self.__children[_i].__dimensions.calculateCoordinates();
					self.__children[_i].updateChildrenPositions();
				}
			}
			static deleteChildren = function(_id) {
				var _i=0; 
				var _n = array_length(self.__children);
				var _found = false;
				while (_i<_n && !_found) {
					if (self.__children[_i].__ID == _id) {
						array_delete(self.__children, _i, 1);
						_found = true;						
					}
					else {
						_i++
					}					
				}
				return _found;
			}
			static getAllChildren = function() {
				var _a = [];
				array_copy(_a, 0, self.getChildren(), 0, array_length(self.getChildren()));
				var _n = array_length(_a);
				if (_n == 0) {
					return [];
				}
				else {
					for (var _i=0; _i<_n; _i++) {
						var _b = _a[_i].getAllChildren();				
						var _m = array_length(_b);
						for (var _j=0; _j<_m; _j++) {
							array_push(_a, _b[_j]);
						}						
					}
					return _a;
				}
			}
						
			static render = function(_absolute_coords = true) {
				if (self.__visible) {
					// Draw this widget
					self.__draw(_absolute_coords);
					//show_debug_message("Rendering "+self.__ID+" (clip="+string(self.__clips_content)+") type = "+string(_absolute_coords)+" abs="+string(self.__dimensions.x)+","+string(self.__dimensions.y)+" / rel="+string(self.__dimensions.relative_x)+","+string(self.__dimensions.relative_y));
					
					if (self.__clips_content) {
						if (!surface_exists(self.__surface_id)) self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
						surface_set_target(self.__surface_id);
						draw_clear_alpha(c_black, 0);
						//gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
						
					}
										
					// Render children - if the widget clips content, then render them with relative coordinates; otherwise, render them with absolute coordinates
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].render(true);
					
					if (self.__clips_content) {
						gpu_set_blendmode(bm_normal);
						surface_reset_target();
						// The surface needs to be drawn with screen coords
						draw_surface_part(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * obj_UI.getScale(), self.__dimensions.height * obj_UI.getScale(), self.__dimensions.x, self.__dimensions.y);
					}
				}
			}
			static processEvents = function() {
				array_copy(self.__events_fired_last, 0, self.__events_fired, 0, UI_NUM_CALLBACKS);
				for (var _i=0; _i<UI_NUM_CALLBACKS; _i++)	self.__events_fired[_i] = false;
				if (self.__visible && self.__enabled) {
					self.__events_fired[UI_EVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), self.__dimensions.x, self.__dimensions.y, self.__dimensions.x + self.__dimensions.width * obj_UI.getScale(), self.__dimensions.y + self.__dimensions.height * obj_UI.getScale());
					self.__events_fired[UI_EVENT.LEFT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UI_EVENT.MIDDLE_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UI_EVENT.RIGHT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UI_EVENT.LEFT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UI_EVENT.MIDDLE_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UI_EVENT.RIGHT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UI_EVENT.LEFT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UI_EVENT.MIDDLE_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UI_EVENT.RIGHT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UI_EVENT.MOUSE_ENTER] = !self.__events_fired_last[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER];
					self.__events_fired[UI_EVENT.MOUSE_EXIT] = self.__events_fired_last[UI_EVENT.MOUSE_OVER] && !self.__events_fired[UI_EVENT.MOUSE_OVER];
					self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_up();
					self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_down();
					
					// Calculate 3x3 "grid" on the panel, based off on screen coords, that will determine what drag action is fired (move or resize)
					var _w = self.__resize_border_width * obj_UI.getScale();					
					var _x0 = self.__dimensions.x;
					var _x1 = _x0 + _w;
					var _x3 = self.__dimensions.x + self.__dimensions.width * obj_UI.getScale();
					var _x2 = _x3 - _w;
					var _y0 = self.__dimensions.y;
					var _y1 = _y0 + _w;
					var _y3 = self.__dimensions.y + self.__dimensions.height * obj_UI.getScale();
					var _y2 = _y3 - _w;
					
					// Determine mouse cursors for mouseover
					if (self.__events_fired[UI_EVENT.MOUSE_OVER]) {
						var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
						if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y1))			window_set_cursor(cr_size_nwse);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y1))		window_set_cursor(cr_size_nesw);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x1, _y3))		window_set_cursor(cr_size_nesw);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y2, _x3, _y3))		window_set_cursor(cr_size_nwse);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x3, _y1))		window_set_cursor(cr_size_ns);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y3))		window_set_cursor(cr_size_we);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x3, _y3))		window_set_cursor(cr_size_ns);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y3))		window_set_cursor(cr_size_we);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))	window_set_cursor(cr_drag);
					}
					
					
					if (obj_UI.__currentlyDraggedWidget == noone && self.__events_fired[UI_EVENT.LEFT_HOLD])	{
						obj_UI.__currentlyDraggedWidget = self;
						obj_UI.__drag_start_x = self.__dimensions.x;
						obj_UI.__drag_start_y = self.__dimensions.y;
						obj_UI.__drag_start_width = self.__dimensions.width;
						obj_UI.__drag_start_height = self.__dimensions.height;
						obj_UI.__drag_mouse_delta_x = device_mouse_x_to_gui(obj_UI.getMouseDevice());
						obj_UI.__drag_mouse_delta_y = device_mouse_y_to_gui(obj_UI.getMouseDevice());
						
						// Determine drag actions for left hold
						var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
						if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))			obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NW; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NE; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SW; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SE; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_N;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_E;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_S;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_W;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	obj_UI.__drag_action = UI_RESIZE_DRAG.DRAG;
						else 	obj_UI.__drag_action = UI_RESIZE_DRAG.NONE;
						
					}
					if (obj_UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left)) {
						obj_UI.__currentlyDraggedWidget = noone;
						obj_UI.__drag_start_x = -1;
						obj_UI.__drag_start_y = -1;
						obj_UI.__drag_start_width = -1;
						obj_UI.__drag_start_height = -1;
						obj_UI.__drag_mouse_delta_x = -1;
						obj_UI.__drag_mouse_delta_y = -1;
						obj_UI.__drag_action = -1;
						window_set_cursor(cr_default);
					}
				}
			}
			static cleanUp = function() {
				if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
				for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
					self.__children[_i].cleanUp();
				}				
				obj_UI.destroy(self);
				obj_UI.__currentlyDraggedWidget = noone;
				obj_UI.__currentlyHoveredPanel = noone;
			}
		#endregion		
	}
#endregion