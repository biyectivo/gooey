/// @feather ignore all
#region UIToggleButton

	/// @constructor	UIToggleButton(_id, _x, _y, _width, _height, _text, _sprite, [_sprite_on], [_value=false], [_relative_to=UI_DEFAULT_ANCHOR_POINT])
	/// @extends		UIButton
	/// @description	A Button that keeps an on/off state: every click toggles it, and it is drawn with a different sprite (and optionally text) while on.
	///					Useful for tool selections, mute buttons, filters, "pinned" states, etc. It fires `VALUE_CHANGED` with `(old, new)` when the value changes, and supports bindings (the bound variable must be boolean).
	/// @param			{String}			_id				The Toggle Button's name, a unique string ID. If the specified name is taken, it will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the Toggle Button, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the Toggle Button, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_width			The width of the Toggle Button
	/// @param			{Real}				_height			The height of the Toggle Button
	/// @param			{String}			_text			The text to display for the Toggle Button
	/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use while the button is off
	/// @param			{Asset.GMSprite}	[_sprite_on]	The sprite ID to use while the button is on (by default, the same as `_sprite`)
	/// @param			{Bool}				[_value]		The initial value (default: false)
	/// @param			{Enum}				[_relative_to]	The position relative to which the Toggle Button will be drawn. By default, uses UI_DEFAULT_ANCHOR_POINT macro in the config.
	/// @return			{UIToggleButton}	self
	function UIToggleButton(_id, _x, _y, _width, _height, _text, _sprite, _sprite_on = undefined, _value = false, _relative_to = UI_DEFAULT_ANCHOR_POINT) : UIButton(_id, _x, _y, _width, _height, _text, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.TOGGLE_BUTTON;
			self.__value = _value;
			self.__sprite_on = _sprite_on ?? _sprite;
			self.__text_on = undefined;			// when undefined, the regular text is used for the on state as well
		#endregion
		#region Setters/Getters
			/// @method				getValue()
			/// @description		Gets whether the Toggle Button is on
			/// @return				{Bool}	whether the Toggle Button is on
			static getValue = function()	{ return self.__value; }

			/// @method				setValue(_value)
			/// @description		Sets whether the Toggle Button is on. Fires `VALUE_CHANGED` (and updates the binding) only if the value changes.
			/// @param				{Bool}	_value	the value to set
			/// @return				{UIToggleButton}	self
			static setValue = function(_value) {
				var _old = self.__value;
				var _new = _value ? true : false;
				if (_old != _new) {
					self.__value = _new;
					if (!is_undefined(self.__binding))	self.__updateBoundVariable(_new);
					self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
				}
				return self;
			}

			/// @method				toggle()
			/// @description		Flips the value of the Toggle Button
			/// @return				{UIToggleButton}	self
			static toggle = function()	{ return self.setValue(!self.__value); }

			/// @method				getSpriteOn()
			/// @description		Gets the sprite used while the button is on
			/// @return				{Asset.GMSprite}	the sprite
			static getSpriteOn = function()	{ return self.__sprite_on; }

			/// @method				setSpriteOn(_sprite)
			/// @description		Sets the sprite used while the button is on
			/// @param				{Asset.GMSprite}	_sprite	the sprite
			/// @return				{UIToggleButton}	self
			static setSpriteOn = function(_sprite)	{ self.__sprite_on = _sprite; return self; }

			/// @method				getTextOn()
			/// @description		Gets the text used while the button is on, or `undefined` if the regular text is used
			/// @return				{String}	the text
			static getTextOn = function()	{ return self.__text_on; }

			/// @method				setTextOn(_text)
			/// @description		Sets the text used while the button is on. Use `undefined` to use the regular text.
			/// @param				{String}	_text	the text
			/// @return				{UIToggleButton}	self
			static setTextOn = function(_text)	{ self.__text_on = _text; return self; }
		#endregion
		#region Methods
			self.__cull_mode = 0;	// the 'on' text and sprites can be bigger than the regular ones
			self.__button_draw = method(self, __draw);
			self.__draw = function() {
				if (!self.__value) {
					self.__button_draw();
					return;
				}
				// Draw as a regular button, temporarily swapping the sprites (and text) for their "on" versions
				var _s = self.__sprite, _sm = self.__sprite_mouseover, _sc = self.__sprite_click;
				var _t = self.__text, _tm = self.__text_mouseover, _tc = self.__text_click;
				self.__sprite = self.__sprite_on;
				self.__sprite_mouseover = self.__sprite_on;
				self.__sprite_click = self.__sprite_on;
				if (!is_undefined(self.__text_on)) {
					self.__text = self.__text_on;
					self.__text_mouseover = self.__text_on;
					self.__text_click = self.__text_on;
				}
				self.__button_draw();
				self.__sprite = _s;
				self.__sprite_mouseover = _sm;
				self.__sprite_click = _sc;
				self.__text = _t;
				self.__text_mouseover = _tm;
				self.__text_click = _tc;
			}

			self.__button_behavior = method(self, __builtInBehavior);
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK])	self.toggle();
				self.__button_behavior();
			}
		#endregion
		// Do not register since it extends UIButton and that one already registers
		return self;
	}

#endregion
