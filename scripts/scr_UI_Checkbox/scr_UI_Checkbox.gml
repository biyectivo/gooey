/// @feather ignore all
#region UICheckbox
	
	/// @constructor	UICheckbox(_id, _x, _y, _text, _sprite_true, _sprite_false, [_value=false], [_relative_to=UI_DEFAULT_ANCHOR_POINT])
	/// @extends		UIWidget
	/// @description	A Checkbox widget, clickable UI widget that stores a true/false state
	/// @param			{String}			_id				The Checkbox's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the Checkbox, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the Checkbox, **relative to its parent**, according to the _relative_to parameter	
	/// @param			{String}			_text			The text to display for the Checkbox
	/// @param			{Asset.GMSprite}	_sprite_true	The sprite ID to use for rendering the Checkbox when true
	/// @param			{Asset.GMSprite}	_sprite_false	The sprite ID to use for rendering the Checkbox when false
	/// @param			{Bool}				[_value]		The initial value of the Checkbox (default=false)
	/// @param			{Enum}				[_relative_to]	The position relative to which the Checkbox will be drawn. By default, uses UI_DEFAULT_ANCHOR_POINT macro in the config (top left if not changed) <br>
	///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UICheckbox}						self
	function UICheckbox(_id, _x, _y, _text, _sprite_true, _sprite_false, _value=false, _relative_to=UI_DEFAULT_ANCHOR_POINT) : __UIWidget(_id, _x, _y, 0, 0, _sprite_true, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.CHECKBOX;
			self.__text_false = _text;
			self.__text_true = _text;
			self.__text_offset = {x: 0, y: 0};
			self.__text_format_true = "[fa_left]";
			self.__text_format_false = "[fa_left]";
			self.__text_format_mouseover_false = "[fa_left]";
			self.__text_format_mouseover_true = "[fa_left]";
			self.__sprite_base = -1;
			self.__sprite_false = _sprite_false;
			self.__sprite_true = _sprite_true;
			self.__sprite_mouseover_false = _sprite_false;			
			self.__sprite_mouseover_true = _sprite_true;
			self.__image_base = 0;
			self.__image_false = 0;
			self.__image_true = 0;
			self.__image_mouseover_false = 0;
			self.__image_mouseover_true = 0;
			self.__inner_sprite_offset = {x: 0, y: 0};
			self.__value = _value;
		#endregion
		#region Setters/Getters			
			/// @method				getRawTextTrue()
			/// @description		Gets the text of the checkbox on the true state, without Scribble formatting tags.
			///	@return				{String}	The text, without Scribble formatting tags.			
			static getRawTextTrue = function()					{ return UI_TEXT_RENDERER(self.__text_true).get_text(); }
			
			/// @method				getTextTrue()
			/// @description		Gets the Scribble text string of the checkbox on the true state.
			///	@return				{String}	The Scribble text string.
			static getTextTrue = function()						{ return self.__text_true; }
			
			/// @method				setTextTrue(_text)
			/// @description		Sets the Scribble text string of the checkbox on the true state.
			/// @param				{String}	_text	The Scribble string to assign to the checbox for the true state.			
			/// @return				{UICheckbox}	self
			static setTextTrue = function(_text)					{ self.__text_true = _text; return self; }
				
			/// @method				getRawTextFalse()
			/// @description		Gets the text of the checkbox on the false state, without Scribble formatting tags.
			///	@return				{String}	The text, without Scribble formatting tags.			
			static getRawTextFalse = function()					{ return UI_TEXT_RENDERER(self.__text_false).get_text(); }
			
			/// @method				getTextFalse()
			/// @description		Gets the Scribble text string of the checkbox on the false state.
			///	@return				{String}	The Scribble text string.
			static getTextFalse = function()						{ return self.__text_false; }
			
			/// @method				setTextFalse(_text)
			/// @description		Sets the Scribble text string of the checkbox on the false state.
			/// @param				{String}	_text	The Scribble string to assign to the checbox for the false state.			
			/// @return				{UICheckbox}	self
			static setTextFalse = function(_text)					{ self.__text_false = _text; return self; }
		
			/// @method				getSpriteTrue()
			/// @description		Gets the sprite ID of the checkbox used for the true state.
			/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the true state.
			static getSpriteTrue = function()				{ return self.__sprite_true; }
			
			/// @method				setSpriteTrue(_sprite)
			/// @description		Sets the sprite to be used for the true state.
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UICheckbox}	self
			static setSpriteTrue = function(_sprite)			{ self.__sprite_true = _sprite; return self; }
			
			/// @method				getImageTrue()
			/// @description		Gets the image index of the checkbox used for the true state.
			/// @return				{Real}	The image index of the checkbox used for the true state.
			static getImageTrue = function()					{ return self.__image_true; }
			
			/// @method				setImageTrue(_image)
			/// @description		Sets the image index of the checkbox used for the true state.
			/// @param				{Real}	_image	The image index
			/// @return				{UICheckbox}	self
			static setImageTrue = function(_image)			{ self.__image_true = _image; return self; }				
				
			/// @method				getSpriteFalse()
			/// @description		Gets the sprite ID of the checkbox used for the false state.	
			/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the false state.	
			static getSpriteFalse = function()				{ return self.__sprite_false; }
			
			/// @method				setSpriteFalse(_sprite)
			/// @description		Sets the sprite to be used for the false state.	
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UICheckbox}	self
			static setSpriteFalse = function(_sprite)			{ self.__sprite_false = _sprite; return self; }
				
			/// @method				getSpriteBase()
			/// @description		Gets the sprite ID of the checkbox base.	
			/// @return				{Asset.GMSprite}	The sprite ID of the checkbox base.	
			static getSpriteBase = function()				{ return self.__sprite_base; }
			
			/// @method				setSpriteBase(_sprite)
			/// @description		Sets the sprite ID of the checkbox base.	
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UICheckbox}	self
			static setSpriteBase = function(_sprite)			{ self.__sprite_base = _sprite; return self; }
				
			/// @method				getImageFalse()
			/// @description		Gets the image index of the checkbox used for the false state.		
			/// @return				{Real}	The image index of the checkbox  used for the false state.	
			static getImageFalse = function()					{ return self.__image_false; }
			
			/// @method				setImageFalse(_image)
			/// @description		Sets the image index of the checkbox used for the false state.	
			/// @param				{Real}	_image	The image index
			/// @return				{UICheckbox}	self
			static setImageFalse = function(_image)			{ self.__image_false = _image; return self; }
				
			/// @method				getImageBase()
			/// @description		Gets the image index of the base sprite for the checkbox.
			/// @return				{Real}	The image index
			static getImageBase = function()					{ return self.__image_base; }
			
			/// @method				setImageBase(_image)
			/// @description		Sets the image index of the base sprite for the checkbox.
			/// @param				{Real}	_image	The image index
			/// @return				{UICheckbox}	self
			static setImageBase = function(_image)			{ self.__image_base = _image; return self; }	
				
			/// @method			getSpriteMouseoverFalse()
			/// @description	Gets the sprite for the false state when mouseovered
			/// @return	{Any}	the sprite
			static getSpriteMouseoverFalse = function() {
				return self.__sprite_mouseover_false;
			}

			/// @method			setSpriteMouseoverFalse(_sprite)
			/// @description	Sets the sprite for the false state when mouseovered
			/// @param	{Any}	_sprite	the sprite to set
			/// @return	{Struct}	self
			static setSpriteMouseoverFalse = function(_sprite) {
				self.__sprite_mouseover_false = _sprite;
				return self;
			}

			/// @method			getSpriteMouseoverTrue()
			/// @description	Gets the sprite for the true state when mouseovered
			/// @return	{Any}	the sprite
			static getSpriteMouseoverTrue = function() {
				return self.__sprite_mouseover_true;
			}

			/// @method			setSpriteMouseoverTrue(_sprite)
			/// @description	Sets the sprite for the true state when mouseovered
			/// @param	{Any}	_sprite	the sprite to set
			/// @return	{Struct}	self
			static setSpriteMouseoverTrue = function(_sprite) {
				self.__sprite_mouseover_true = _sprite;
				return self;
			}

			/// @method			getImageMouseoverFalse()
			/// @description	Gets the image for the false state when mouseovered
			/// @return	{Any}	the image index
			static getImageMouseoverFalse = function() {
				return self.__image_mouseover_false;
			}

			/// @method			setImageMouseoverFalse(_image)
			/// @description	Sets the image for the false state when mouseovered
			/// @param	{Any}	_image	the image index to set
			/// @return	{Struct}	self
			static setImageMouseoverFalse = function(_image) {
				self.__image_mouseover_false = _image;
				return self;
			}

			/// @method			getImageMouseoverTrue()
			/// @description	Gets the image for the true state when mouseovered
			/// @return	{Any}	the image index
			static getImageMouseoverTrue = function() {
				return self.__image_mouseover_true;
			}

			/// @method			setImageMouseoverTrue(_image)
			/// @description	Sets the image for the true state when mouseovered
			/// @param	{Any}	_image	the image index to set
			/// @return	{Struct}	self
			static setImageMouseoverTrue = function(_image) {
				self.__image_mouseover_true = _image;
				return self;
			}

			/// @method			getTextFormatMouseoverFalse()
			/// @description	Gets the format of the text for the false state when mouseovered
			/// @return	{Any}	the format
			static getTextFormatMouseoverFalse = function() {
				return self.__text_format_mouseover_false;
			}

			/// @method			setTextFormatMouseoverFalse(_format)
			/// @description	Sets the format of the text for the false state when mouseovered
			/// @param	{Any}	_format	the format to set
			/// @return	{Struct}	self
			static setTextFormatMouseoverFalse = function(_format) {
				self.__text_format_mouseover_false = _format;
				return self;
			}

			/// @method			getTextFormatMouseoverTrue()
			/// @description	Gets the format of the text for the true state when mouseovered
			/// @return	{Any}	the format
			static getTextFormatMouseoverTrue = function() {
				return self.__text_format_mouseover_true;
			}

			/// @method			setTextFormatMouseoverTrue(_format)
			/// @description	Sets the format of the text for the true state when mouseovered
			/// @param	{Any}	_format	the format to set
			/// @return	{Struct}	self
			static setTextFormatMouseoverTrue = function(_format) {
				self.__text_format_mouseover_true = _format;
				return self;
			}

			/// @method			getTextFormatTrue()
			/// @description	Gets the format of the text for the true state
			/// @return	{Any}	the format
			static getTextFormatTrue = function() {
				return self.__text_format_true;
			}

			/// @method			setTextFormatTrue(_format)
			/// @description	Sets the format of the text for the true state
			/// @param	{Any}	_format	the format to set
			/// @return	{Struct}	self
			static setTextFormatTrue = function(_format) {
				self.__text_format_true = _format;
				return self;
			}

			/// @method			getTextFormatFalse()
			/// @description	Gets the format of the text for the false state
			/// @return	{Any}	the format
			static getTextFormatFalse = function() {
				return self.__text_format_false;
			}

			/// @method			setTextFormatFalse(_format)
			/// @description	Sets the format of the text for the false state
			/// @param	{Any}	_format	the format to set
			/// @return	{Struct}	self
			static setTextFormatFalse = function(_format) {
				self.__text_format_false = _format;
				return self;
			}

			/// @method				getValue()
			/// @description		Gets the value of the checkbox
			/// @return				{Bool}	the value of the checkbox
			static getValue = function()						{ return self.__value; }
				
			/// @method				setValue(_value)
			/// @description		Sets the value of the checkbox
			/// @param				{Bool}	_value	the value to set
			/// @return				{UICheckbox}	self
			static setValue = function(_value) {
				var _old = self.__value;
				var _new = _value;
				var _changed = (_old != _new);
				if (_changed) {
					self.__value = _new;	
					if (!is_undefined(self.__binding)) {
						self.__updateBoundVariable(_new);
					}
					self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);					
				}
				return self;
			}
				
			/// @method				toggle()
			/// @description		Toggles the value of the checkbox
			/// @return				{UICheckbox}	self
			static toggle = function() { 					
				self.setValue(!self.getValue());
				return self;
			}
				
			/// @method				getTextOffset()
			/// @description		Gets the text x-y offset for the checkbox, starting from the anchor point
			/// @return				{Struct}	A struct with x and y position
			static getTextOffset = function()						{ return self.__text_offset; }
			
			/// @method				setTextOffset(_offset)
			/// @description		Sets the text x-y offset for the checkbox, starting from the anchor point
			/// @param				{Struct}	_offset		A struct with x and y position
			/// @return				{UIButton}	self
			static setTextOffset = function(_offset)			{ self.__text_offset = _offset; return self; }
				
			/// @method				getInnerSpritesOffset()
			/// @description		Gets the x-y offset for the checkbox inner true/false sprites relative to the top-left of the base sprite
			/// @return				{Struct}	A struct with x and y position
			static getInnerSpritesOffset = function()						{ return self.__inner_sprite_offset; }
			
			/// @method				setInnerSpritesOffset(_offset)
			/// @description		Sets the x-y offset for the checkbox inner true/false sprites relative to the top-left of the base sprite
			/// @param				{Struct}	_offset		A struct with x and y position
			/// @return				{UIButton}	self
			static setInnerSpritesOffset = function(_offset)			{ self.__inner_sprite_offset = _offset; return self; }
								
		#endregion
		#region Methods
			// Computes the size of the widget (sprites + text) so it is known, and clickable, even before the first draw
			static __updateSize = function() {
				var _scale = global.__gooey_manager_active.__scale;
				var _sprite = self.__value ? self.__sprite_true : self.__sprite_false;
				var _width = (sprite_exists(_sprite) ? sprite_get_width(_sprite) : 0) * _scale;
				var _height = (sprite_exists(_sprite) ? sprite_get_height(_sprite) : 0) * _scale;
				var _width_base = sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) * _scale : 0;
				var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) * _scale : 0;
				var _fmt = self.__value ? self.__text_format_true : self.__text_format_false;
				var _s = UI_TEXT_RENDERER("[scale,"+string(_scale)+"]"+_fmt+(self.__value ? self.__text_true : self.__text_false));
				self.setDimensions(,, max(_width, _width_base) + _s.get_width() + self.__text_offset.x, max(_width * 0 + _height, _height_base, _s.get_height() + self.__text_offset.y));
			}
			
			self.__draw = function() {
				var _x = self.__dimensions.x;
				var _y = self.__dimensions.y;
				var _w_true = sprite_exists(self.__sprite_true) ? sprite_get_width(self.__sprite_true) : 0;
				var _h_true = sprite_exists(self.__sprite_true) ? sprite_get_height(self.__sprite_true) : 0;
				var _w_false = sprite_exists(self.__sprite_false) ? sprite_get_width(self.__sprite_false) : 0;
				var _h_false = sprite_exists(self.__sprite_false) ? sprite_get_height(self.__sprite_false) : 0;
					
				var _width = (self.__value ? _w_true : _w_false) * global.__gooey_manager_active.__scale;
				var _height = (self.__value ? _h_true : _h_false) * global.__gooey_manager_active.__scale;
				var _width_base = sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) * global.__gooey_manager_active.__scale : 0;
				var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) * global.__gooey_manager_active.__scale : 0;
					
				var _sprite = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__sprite_mouseover_true : self.__sprite_mouseover_false) : (self.__value ? self.__sprite_true : self.__sprite_false);
				var _image = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__image_mouseover_true : self.__image_mouseover_false) : (self.__value ? self.__image_true : self.__image_false);
				var _text = self.__value ? self.__text_true : self.__text_false;
				var _fmt = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__text_format_mouseover_true : self.__text_format_mouseover_false) : (self.__value ? self.__text_format_true : self.__text_format_false);
					
				if (sprite_exists(self.__sprite_base)) draw_sprite_stretched_ext(self.__sprite_base, self.__image_base, _x, _y, _width_base, _height_base, self.__image_blend, self.__image_alpha); 
				if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _x + self.__inner_sprite_offset.x, _y + self.__inner_sprite_offset.y, _width, _height, self.__image_blend, self.__image_alpha);
					
				var _x = _x + max(_width, _width_base);
				var _y = _y + max(_height/2, _height_base/2);
					
				var _scale = global.__gooey_manager_active.__scale_tag;				
				var _s = UI_TEXT_RENDERER(_scale+_fmt+_text);
					
				self.setDimensions(,,max(_width, _width_base) + _s.get_width() + self.__text_offset.x, max(_height, _height_base, _s.get_height() + self.__text_offset.y));
				_s.draw(_x + self.__text_offset.x, _y + self.__text_offset.y);
			}
			self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
					self.toggle();
				}
					
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
				self.__generalBuiltInBehaviors(_arr);
			}
			
		#endregion
		
		self.__register();
		self.__updateSize();
		return self;
	}
	
#endregion
