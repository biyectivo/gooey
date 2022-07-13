#region Helper Enums and Macros
	#macro NUM_CALLBACKS 14
	enum UIEVENT {
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
	enum UITYPE {
		PANEL,
		BUTTON,
		GROUP
	}
	enum UIRESIZEDRAG {
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
	enum UIANCHOR_H {
		LEFT,
		CENTER,
		RIGHT
	}
#endregion

#region Helper Functions
	
#endregion

#region Widgets

	function UIPanel(_id, _x, _y, _width, _height, _sprite) : __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__type = UITYPE.PANEL;			
			self.__draggable = true;
			self.__drag_bar_height = 20;
			self.__resizable = true;			
			self.__resize_border_width = 10;
			self.__title = "";
			self.__title_horizontal_anchor = UIANCHOR_H.CENTER;
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
					deleteChildren(_id);
				}
				else {
					self.__close_button = _button_id;
					self.__close_button.__ID = _id;
					add(self.__close_button);
					self.__close_button.setCallback(UIEVENT.LEFT_CLICK, function() {
						self.cleanUp();						
					});
					self.anchorChildren();
				}
			}
		#endregion
		#region Methods
			self.__draw = function() {
				var _x = self.__dimensions.x + self.__dimensions.anchor_x;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);
				// Title
				if (self.__title != "")	{
					var _s = scribble(self.__title);
					var _h = _s.get_height();
					var _title_x = self.__title_horizontal_anchor == UIANCHOR_H.LEFT ? _x : (self.__title_horizontal_anchor == UIANCHOR_H.CENTER ? _x+_width/2 : _x+_width);
					var _title_y = self.__drag_bar_height == self.__dimensions.height ? _y + _h/2 : _y + self.__drag_bar_height;
					_s.draw(_title_x, _title_y);
				}
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UIEVENT.LEFT_CLICK])	obj_UI.setPanelFocus(self);				
			}
			self.__drag = function() {					
				if (self.__draggable && obj_UI.__drag_action == UIRESIZEDRAG.DRAG) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_SE) {
					self.__dimensions.width = obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.height = obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_NE) {
					self.__dimensions.width = obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice());
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_SW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice());
					self.__dimensions.height = obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.anchorChildren();		
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_NW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.width = obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice());
					self.__dimensions.height = obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice());
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_N) {
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice());
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_S) {
					self.__dimensions.height = obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_W) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice());
					self.anchorChildren();
				}
				else if (self.__resizable && obj_UI.__drag_action == UIRESIZEDRAG.RESIZE_E) {
					self.__dimensions.width = obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.anchorChildren();
				}
			}
		#endregion
			
		self.register();
		return self;
	}
	
	function UIButton(_id, _x, _y, _width, _height, _text, _sprite) : __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__type = UITYPE.BUTTON;
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
			self.__draw = function() {
				var _x = self.__dimensions.x + self.__dimensions.anchor_x;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				
				var _sprite = self.__sprite;
				var _image = self.__image;
				var _text = self.__text;
				if (self.__events_fired[UIEVENT.MOUSE_OVER])	{					
					_sprite =	self.__events_fired[UIEVENT.LEFT_HOLD] ? self.__sprite_click : self.__sprite_mouseover;
					_image =	self.__events_fired[UIEVENT.LEFT_HOLD] ? self.__image_click : self.__image_mouseover;
					_text =		self.__events_fired[UIEVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
				}
				draw_sprite_stretched(_sprite, _image, _x, _y, _width, _height);
				var _x = self.__dimensions.x + self.__dimensions.anchor_x + self.__dimensions.width * obj_UI.getScale()/2;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y + self.__dimensions.height * obj_UI.getScale()/2;
				var _scale = "[scale,"+string(obj_UI.getScale())+"]";
				
				scribble(_scale+_text).draw(_x, _y);
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UIEVENT.LEFT_CLICK]) 	self.__callbacks[UIEVENT.LEFT_CLICK]();				
			}
		#endregion
		
		self.register();
		return self;
	}
	
	function UIGroup(_id, _x, _y, _width, _height, _sprite) : __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__type = UITYPE.GROUP;	
		#endregion
		#region Setters/Getters
			
		#endregion
		#region Methods
			self.__draw = function() {
				var _x = self.__dimensions.x + self.__dimensions.anchor_x;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);				
			}
			self.__builtInBehavior = function() {
				if (self.__events_fired[UIEVENT.LEFT_CLICK]) 	self.__callbacks[UIEVENT.LEFT_CLICK]();				
			}
		#endregion
		
		self.register();
		return self;
	}

#endregion


#region Helper Structs
	function None() {}
	function __UIDimensions(_x, _y, _width, _height, _anchor_x = 0, _anchor_y = 0) constructor {
		self.x = _x;
		self.y = _y;
		self.width = _width;
		self.height = _height;
		self.anchor_x = _anchor_x;
		self.anchor_y = _anchor_y;		
	}	
	function __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__ID = _id;
			self.__type = -1;
			self.__dimensions = new __UIDimensions(_x, _y, _width, _height);
			self.__sprite = _sprite;
			self.__image = 0;
			self.__events_fired_last = array_create(NUM_CALLBACKS, false);
			self.__events_fired = array_create(NUM_CALLBACKS, false);
			self.__callbacks = array_create(NUM_CALLBACKS, None);
			self.__parent = noone;
			self.__children = [];
			self.__builtInBehavior = None;			
			self.__visible = true;
			self.__enabled = true;
			self.__draggable = false;			
			self.__resizable = false;
			self.__resize_border_width = 0;
			self.__drag_bar_height = self.__dimensions.height;
		#endregion
		#region Setters/Getters
			static getID = function()					{ return self.__ID; }
			static getType = function()					{ return self.__type; }			
			static getDimensions = function()			{ return self.__dimensions; }
			static setDimensions = function(_x=undefined, _y=undefined, _width=undefined, _height=undefined)	{
				self.__dimensions.x ??= _x;
				self.__dimensions.y ??= _y;
				self.__dimensions.width ??= _width;
				self.__dimensions.height ??= _height;
			}			
			static getSprite = function()				{ return self.__sprite; }
			static setSprite = function(_sprite)		{ self.__sprite = _sprite; }
			static getCallback = function(_callback_type)				{ return self.__callbacks[_callback_type]; }
			static setCallback = function(_callback_type, _function)	{ self.__callbacks[_callback_type] = _function; }
			static getParent = function()				{ return self.__parent; }
			static setParent = function(_parent_id)		{ self.__parent = _parent_id; }
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
				_id.__dimensions.anchor_x = self.__dimensions.anchor_x + self.__dimensions.x;
				_id.__dimensions.anchor_y = self.__dimensions.anchor_y + self.__dimensions.y;
				array_push(self.__children, _id);
				return _id;
			}
		#endregion
		#region Methods
			static register = function() {
				obj_UI.register(self);
			}
			static anchorChildren = function(_x = self.__dimensions.x + self.__dimensions.anchor_x, _y = self.__dimensions.y + self.__dimensions.anchor_y) {
				for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
					self.__children[_i].__dimensions.anchor_x = _x;
					self.__children[_i].__dimensions.anchor_y = _y;
					self.__children[_i].anchorChildren();
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
			static render = function() {
				if (self.__visible) {
					self.__draw();
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].render();
				}
			}			
			self.__draw = function() {}
			static processEvents = function() {
				array_copy(self.__events_fired_last, 0, self.__events_fired, 0, NUM_CALLBACKS);
				for (var _i=0; _i<NUM_CALLBACKS; _i++)	self.__events_fired[_i] = false;
				if (self.__visible && self.__enabled) {
					self.__events_fired[UIEVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), self.__dimensions.anchor_x + self.__dimensions.x, self.__dimensions.anchor_y + self.__dimensions.y, self.__dimensions.anchor_x + self.__dimensions.x + self.__dimensions.width * obj_UI.getScale(), self.__dimensions.anchor_y + self.__dimensions.y + self.__dimensions.height * obj_UI.getScale());
					self.__events_fired[UIEVENT.LEFT_CLICK] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UIEVENT.MIDDLE_CLICK] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UIEVENT.RIGHT_CLICK] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UIEVENT.LEFT_HOLD] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UIEVENT.MIDDLE_HOLD] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UIEVENT.RIGHT_HOLD] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UIEVENT.LEFT_RELEASE] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left);
					self.__events_fired[UIEVENT.MIDDLE_RELEASE] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_middle);
					self.__events_fired[UIEVENT.RIGHT_RELEASE] = self.__events_fired[UIEVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_right);
					self.__events_fired[UIEVENT.MOUSE_ENTER] = !self.__events_fired_last[UIEVENT.MOUSE_OVER] && self.__events_fired[UIEVENT.MOUSE_OVER];
					self.__events_fired[UIEVENT.MOUSE_EXIT] = self.__events_fired_last[UIEVENT.MOUSE_OVER] && !self.__events_fired[UIEVENT.MOUSE_OVER];
					self.__events_fired[UIEVENT.MOUSE_WHEEL_UP] = self.__events_fired[UIEVENT.MOUSE_OVER] && mouse_wheel_up();
					self.__events_fired[UIEVENT.MOUSE_WHEEL_DOWN] = self.__events_fired[UIEVENT.MOUSE_OVER] && mouse_wheel_down();
					
					var _w = self.__resize_border_width * obj_UI.getScale();					
					var _x0 = self.__dimensions.x + self.__dimensions.anchor_x;
					var _x1 = _x0 + _w;
					var _x3 = self.__dimensions.x + self.__dimensions.anchor_x + self.__dimensions.width * obj_UI.getScale();
					var _x2 = _x3 - _w;
					var _y0 = self.__dimensions.y + self.__dimensions.anchor_y;
					var _y1 = _y0 + _w;
					var _y3 = self.__dimensions.y + self.__dimensions.anchor_y + self.__dimensions.height * obj_UI.getScale();
					var _y2 = _y3 - _w;
					
					if (self.__events_fired[UIEVENT.MOUSE_OVER]) {
						var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
						if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y1))		window_set_cursor(cr_size_nwse);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y1))		window_set_cursor(cr_size_nesw);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x1, _y3))		window_set_cursor(cr_size_nesw);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y2, _x3, _y3))		window_set_cursor(cr_size_nwse);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x3, _y1))		window_set_cursor(cr_size_ns);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y3))		window_set_cursor(cr_size_we);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x3, _y3))		window_set_cursor(cr_size_ns);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y3))		window_set_cursor(cr_size_we);
						else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))		window_set_cursor(cr_drag);
					}
					
					if (obj_UI.__currentlyDraggedWidget == noone && self.__events_fired[UIEVENT.LEFT_HOLD])	{
						obj_UI.__currentlyDraggedWidget = self;
						obj_UI.__drag_start_x = self.__dimensions.x;
						obj_UI.__drag_start_y = self.__dimensions.y;
						obj_UI.__drag_start_width = self.__dimensions.width;
						obj_UI.__drag_start_height = self.__dimensions.height;
						obj_UI.__drag_mouse_delta_x = device_mouse_x_to_gui(obj_UI.getMouseDevice());
						obj_UI.__drag_mouse_delta_y = device_mouse_y_to_gui(obj_UI.getMouseDevice());
						
						var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
						if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))		obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_NW; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_NE; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_SW; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_SE; 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_N;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_E;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_S;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))	obj_UI.__drag_action = UIRESIZEDRAG.RESIZE_W;	 
						else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	obj_UI.__drag_action = UIRESIZEDRAG.DRAG;
						else 	obj_UI.__drag_action = UIRESIZEDRAG.NONE;
						
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