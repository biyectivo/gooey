/// @feather ignore all
#region UIDropDown
	
	/// @constructor	UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
	/// @extends		UIOptionGroup
	/// @description	A Dropdown widget, clickable UI widget that lets the user select from a list of values. Extends UIOptionGroup as it provides the same functionality with different interface.
	/// @param			{String}			_id					The Dropdown's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x					The x position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y					The y position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Array<String>}		_option_array		An array with at least one string that contains the text for each of the options
	/// @param			{Asset.GMSprite}	_sprite_dropdown	The sprite ID to use for rendering the background of the list of values
	/// @param			{Asset.GMSprite}	_sprite				The sprite ID to use for rendering each value within the list of values
	/// @param			{Real}				[_initial_idx]		The initial selected index of the Dropdown list (default=0, the first option)
	/// @param			{Enum}				[_relative_to]		The position relative to which the Dropdown will be drawn. By default, the top left (TOP_LEFT) <br>
	///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UIDropdown}							self
	function UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, _initial_idx=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : UIOptionGroup(_id, _x, _y, _option_array, _sprite, _initial_idx, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.DROPDOWN;
			self.__sprite_arrow = noone;
			self.__image_arrow = 0;
			self.__sprite_dropdown = _sprite_dropdown;
			self.__image_dropdown = 0;
			self.__dropdown_active = false;
		#endregion
		#region Setters/Getters			
			/// @method				getSpriteDropdown()
			/// @description		Gets the sprite ID of the dropdown background
			/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
			self.getSpriteDropdown = function()				{ return self.__sprite_dropdown; }
			
			/// @method				setSpriteDropdown(_sprite)
			/// @description		Sets the sprite ID of the dropdown background
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIDropdown}	self
			self.setSpriteDropdown = function(_sprite)			{ self.__sprite_dropdown = _sprite; return self; }
			
			/// @method				getImageDropdown()
			/// @description		Gets the image index of the dropdown background
			/// @return				{Real}	The image index of the dropdown background
			self.getImageDropdown = function()					{ return self.__image_dropdown; }
			
			/// @method				setImageDropdown(_image)
			/// @description		Sets the image index of the dropdown background
			/// @param				{Real}	_image	The image index
			/// @return				{UIOptionGroup}	self
			self.setImageDropdown = function(_image)			{ self.__image_dropdown = _image; return self; }
				
			/// @method				getSpriteArrow()
			/// @description		Gets the sprite ID of the arrow icon for the dropdown
			/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
			self.getSpriteArrow = function()				{ return self.__sprite_arrow; }
			
			/// @method				setSpriteArrow(_sprite)
			/// @description		Sets the sprite ID of the arrow icon for the dropdown
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIArrow}	self
			self.setSpriteArrow = function(_sprite)			{ self.__sprite_arrow = _sprite; return self; }
			
			/// @method				getImageArrow()
			/// @description		Gets the image index of the arrow icon for the dropdown
			/// @return				{Real}	The image index of the arrow icon for the dropdown
			self.getImageArrow = function()					{ return self.__image_arrow; }
			
			/// @method				setImageArrow(_image)
			/// @description		Sets the image index of the arrow icon for the dropdown
			/// @param				{Real}	_image	The image index
			/// @return				{UIOptionGroup}	self
			self.setImageArrow = function(_image)			{ self.__image_arrow = _image; return self; }
			
		#endregion
		#region Methods
			self.__draw = function() {
				var _x = self.__dimensions.x;
				var _y = self.__dimensions.y;
				var _pad_left = 10;
				var _pad_right = 10 + (sprite_exists(self.__sprite_arrow) ? sprite_get_width(self.__sprite_arrow) : 0);
				var _pad_top = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
				var _pad_bottom = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
					
				var _sprite = self.__sprite_selected;
				var _image = self.__image_selected;
				var _fmt = self.__text_format_selected;
				var _text = self.__option_array_selected[self.__index];
				var _scale = "[scale,"+string(global.__gooey_manager_active.getScale())+"]";
				var _t = UI_TEXT_RENDERER(_scale+_fmt+_text);						
				var _width = self.__dimensions.width == 0 ? _t.get_width() + _pad_left+_pad_right : self.__dimensions.width;
				var _height = _t.get_height() + _pad_top+_pad_bottom;
					
				if (point_in_rectangle(device_mouse_x_to_gui(global.__gooey_manager_active.getMouseDevice()), device_mouse_y_to_gui(global.__gooey_manager_active.getMouseDevice()), _x, _y, _x + _width, _y + _height)) {
					_sprite =	self.__sprite_mouseover;
					_image =	self.__image_mouseover;
					_fmt =		self.__text_format_mouseover;
					_text =		self.__option_array_mouseover[self.__index];
					_t = UI_TEXT_RENDERER(_scale+_fmt+_text);
				}
					
				if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
						
				var _x = _x + _pad_left;
				var _y = _y + _height * global.__gooey_manager_active.getScale()/2;
				_t.draw(_x, _y);
						
				// Arrow
				var _x = self.__dimensions.x + _width - _pad_right;
				if (sprite_exists(self.__sprite_arrow)) draw_sprite_ext(self.__sprite_arrow, self.__image_arrow, _x, _y - sprite_get_height(self.__sprite_arrow)/2, 1, 1, 0, self.__image_blend, self.__image_alpha);
					
				if (self.__dropdown_active) {  // Draw actual dropdown list
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y + _height;
					var _n = array_length(self.__option_array_unselected);
					if (sprite_exists(self.__sprite_dropdown)) draw_sprite_stretched_ext(self.__sprite_dropdown, self.__image_dropdown, _x, _y, _width, _height * _n + _pad_bottom, self.__image_blend, self.__image_alpha);
						
					var _cum_h = 0;
					_x += _pad_left;
					for (var _i=0; _i<_n; _i++) {	
						var _fmt = self.__text_format_unselected;
						_t = UI_TEXT_RENDERER(_scale+_fmt+self.__option_array_unselected[_i]);
						if (point_in_rectangle(device_mouse_x_to_gui(global.__gooey_manager_active.getMouseDevice()), device_mouse_y_to_gui(global.__gooey_manager_active.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
							_fmt =	self.__text_format_mouseover;
							_t = UI_TEXT_RENDERER(_scale+_fmt+self.__option_array_mouseover[_i]);
						}
						_t.draw(_x, _y + _t.get_height() + _cum_h);
						_cum_h += _t.get_height();
						if (_i<_n-1)  _cum_h += self.__spacing;
					}
				}
					
				self.setDimensions(,,_width, self.__dropdown_active ? _height * (_n+1) + _pad_bottom : _height);
					
			}
			//self.__generalBuiltInBehaviors = method(self, __UIWidget.__builtInBehavior);
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
					if (self.__dropdown_active) {
							
						var _pad_left = 10;
						var _pad_right = 10 + (sprite_exists(self.__sprite_arrow) ? sprite_get_width(self.__sprite_arrow) : 0);
						var _pad_top = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
						var _pad_bottom = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
						var _scale = "[scale,"+string(global.__gooey_manager_active.getScale())+"]";
						var _x = self.__dimensions.x;
						var _y = self.__dimensions.y + UI_TEXT_RENDERER(self.__option_array_selected[self.__index]).get_height() + _pad_top+_pad_bottom;
							
						var _width = self.__dimensions.width;							
							
						var _clicked = -1;
						var _n=array_length(self.__option_array_unselected);
						var _i=0;
						var _cum_h = 0;
						while (_i<_n && _clicked == -1) {
							_t = UI_TEXT_RENDERER(_scale+self.__option_array_mouseover[_i]);
							if (point_in_rectangle(device_mouse_x_to_gui(global.__gooey_manager_active.getMouseDevice()), device_mouse_y_to_gui(global.__gooey_manager_active.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
								_clicked = _i;
							}
							else {
								_cum_h += _t.get_height();
								if (_i<_n-1)  _cum_h += self.__spacing;
								_i++;
							}
						}
						
						if (_clicked != -1 && _clicked != self.__index)	{
							self.setIndex(_clicked);
						}
							
						self.__dropdown_active = false;
					}
					else {
						self.__dropdown_active = true;
					}						
				}
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
				self.__generalBuiltInBehaviors(_arr);
			}
		#endregion
		
		// Do not register since it extends UIOptionGroup and that one already registers
		//self.__register();
		return self;
	}
	
#endregion
	