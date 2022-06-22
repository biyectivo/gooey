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
				if (self.__events_fired[UIEVENT.LEFT_CLICK])	obj_UI.setPanelFocus(self);
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
			self.__dragging = false;
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
				self.__draw();
				for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].render();
			}
			self.__draw = function() {}
			static processEvents = function() {
				array_copy(self.__events_fired_last, 0, self.__events_fired, 0, NUM_CALLBACKS);
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
				//show_debug_message(string(self.__ID)+" "+string(self.__events_fired));				
			}
			self.cleanUp = function() {}
		#endregion		
	}
#endregion