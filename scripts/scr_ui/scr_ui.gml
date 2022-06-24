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
		BUTTON
	}
#endregion

#region Helper Functions
	
#endregion

#region Widgets

	function UIPanel(_id, _x, _y, _width, _height, _sprite) : __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__type = UITYPE.PANEL;			
			self.__draggable = true;
			self.__drag_bar_height = self.__dimensions.height * obj_UI.getScale();
			self.__resizable = true;
			self.__resize_border_width = 10;
			self.__resize_diagonal = true;
		#endregion
		#region Setters/Getters
			self.getDragDimensions = function()			{ return self.__drag_area_dimensions; }
			self.setDragDimensions = function(_x=undefined, _y=undefined, _width=undefined, _height=undefined)	{
				self.__drag_area_dimensions.x ??= _x;
				self.__drag_area_dimensions.y ??= _y;
				self.__drag_area_dimensions.width ??= _width;
				self.__drag_area_dimensions.height ??= _height;
			}
			self.getResizeCornerRadius = function()		{ return self.__resize_corner_radius; }
			self.setResizeCornerRadius = function(_corner_radius)	{ self.__resize_corner_radius = _corner_radius; }
			self.getResizeBorderWidth = function()		{ return self.__resize_border_width; }
			self.setResizeBorderWidth = function(_border_width)		{ self.__resize_border_width = _border_width; }
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
				if (self.__events_fired[UIEVENT.LEFT_CLICK])	obj_UI.setPanelFocus(self);				
			}
			self.__drag = function() {
				var _w = self.__resize_border_width * obj_UI.getScale();
				var _x0 = self.__dimensions.x + self.__dimensions.anchor_x;
				var _x1 = _x0 + _w;
				var _x3 = self.__dimensions.x + self.__dimensions.anchor_x + self.__dimensions.width * obj_UI.getScale();
				var _x2 = _x3 - _w;
				var _y0 = self.__dimensions.y + self.__dimensions.anchor_y;
				var _y1 = _y0 + _w;
				var _y3 = self.__dimensions.y + self.__dimensions.anchor_y + self.__dimensions.height * obj_UI.getScale();
				var _y2 = _y3 - _w;
				
				print("X = $x$ Y = $y$ vs $x0$ $x1$ $x2$ $x3$ $y0$ $y1$ $y2$ $y3$", [obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _x1, _x2, _x3, _y0, _y1, _y2, _y3  ]);
				// Top left corner
				if (self.__resizable && self.__resize_diagonal && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y1)) {
					show_debug_message("Resize top left corner");
				}
				// Top right corner
				else if (self.__resizable && self.__resize_diagonal && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y1)) {
					show_debug_message("Resize top right corner");
				}
				// Bottom left corner
				else if (self.__resizable && self.__resize_diagonal && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x1, _y3)) {
					show_debug_message("Resize bottom left corner");
				}
				// Bottom right corner
				else if (self.__resizable && self.__resize_diagonal && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y2, _x3, _y3)) {
					show_debug_message("Resize bottom right corner");
				}
				// Top border
				else if (self.__resizable && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x3, _y1)) {
					show_debug_message("Resize top border");
				}
				// Right border
				else if (self.__resizable && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y3)) {
					show_debug_message("Resize right border");
				}
				// Bottom border
				else if (self.__resizable && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x3, _y3)) {
					show_debug_message("Resize bottom border");
				}
				// Left border
				else if (self.__resizable && point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y3)) {
					show_debug_message("Resize left border");
				}
				// Drag
				else if (self.__draggable) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.anchorChildren();
				}
			}
			self.cleanUp = function() {}
		#endregion
			
		self.register();
		return self;
	}
	
	function UIButton(_id, _x, _y, _width, _height, _text, _sprite) : __UIWidget(_id, _x, _y, _width, _height, _sprite) constructor {
		#region Private variables
			self.__type = UITYPE.BUTTON;
			self.__text = _text;			
		#endregion
		#region Setters/Getters
			self.getText = function()				{ return self.__text; }
			self.setText = function(_text)			{ self.__text = _text; }		
		#endregion
		#region Methods
			self.__draw = function() {
				var _x = self.__dimensions.x + self.__dimensions.anchor_x;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y;
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);
				var _x = self.__dimensions.x + self.__dimensions.anchor_x + self.__dimensions.width * obj_UI.getScale()/2;
				var _y = self.__dimensions.y + self.__dimensions.anchor_y + self.__dimensions.height * obj_UI.getScale()/2;
				var _scale = "[scale,"+string(obj_UI.getScale())+"]";
				scribble(_scale+self.__text).draw(_x, _y);
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
				
					if (obj_UI.__currentlyDraggedWidget == noone && self.__events_fired[UIEVENT.LEFT_HOLD])	{
						obj_UI.__currentlyDraggedWidget = self;
						obj_UI.__drag_start_x = self.__dimensions.x;
						obj_UI.__drag_start_y = self.__dimensions.y;
						obj_UI.__drag_start_width = self.__dimensions.width;
						obj_UI.__drag_start_height = self.__dimensions.height;
						obj_UI.__drag_mouse_delta_x = device_mouse_x_to_gui(obj_UI.getMouseDevice());
						obj_UI.__drag_mouse_delta_y = device_mouse_y_to_gui(obj_UI.getMouseDevice());
					}
					if (obj_UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left)) {
						obj_UI.__currentlyDraggedWidget = noone;
						obj_UI.__drag_start_x = -1;
						obj_UI.__drag_start_y = -1;
						obj_UI.__drag_start_width = -1;
						obj_UI.__drag_start_height = -1;
						obj_UI.__drag_mouse_delta_x = -1;
						obj_UI.__drag_mouse_delta_y = -1;
					}
										
				}
			}
			self.cleanUp = function() {}
		#endregion		
	}
#endregion