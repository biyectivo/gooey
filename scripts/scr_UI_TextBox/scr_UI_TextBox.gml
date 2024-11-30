/// @feather ignore all
#region UITextBox
	
	/// @constructor	UITextBox(_id, _x, _y, _width, _height, _sprite, _max_chars, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
	/// @extends		UIWidget
	/// @description	A TextBox widget, that allows the user to select a value from a range by dragging, clicking or scrolling
	/// @param			{String}			_id				The TextBox's name, a unique string ID. If the specified name is taken, the TextBox will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the TextBox, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the TextBox, **relative to its parent**, according to the _relative_to parameter	
	/// @param			{Real}				_width			The width of the TextBox
	/// @param			{Real}				_height			The height of the TextBox
	/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the TextBox
	/// @param			{Real}				[_max_chars]	The maximum number of characters for the TextBox, By default, no maximum.
	/// @param			{Enum}				[_relative_to]	The position relative to which the TextBox will be drawn. By default, the top left (TOP_LEFT) <br>
	///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UITextBox}							self
	function UITextBox(_id, _x, _y, _width, _height, _sprite, _max_chars=999999999, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.TEXTBOX;
			self.__text = "";
			self.__placeholder_text = "";
			self.__max_chars = _max_chars <= 0 ? 999999999 : _max_chars;
			self.__mask_text = false;
			self.__mask_char = "*";
			self.__multiline = false;
			self.__cursor_pos = -1;
			self.__currently_editing = false;
			self.__read_only = false;
			self.__allow_uppercase_letters = true;
			self.__allow_lowercase_letters = true;
			self.__allow_spaces = true;
			self.__allow_digits = true;
			self.__allow_symbols = true;
			self.__symbols_allowed = "";
			self.__allow_cursor_mouse = true;
			self.__allow_cursor_keyboard = false;
			self.__text_anchor = UI_RELATIVE_TO.TOP_LEFT;
			self.__text_format = "";
			self.__text_margin = 2;
				
			self.__display_starting_char = 0;
			self.__surface_id = -1;
				
			// Adjust width/height to consider margin
			self.__dimensions.set(,, self.__dimensions.width + 2*self.__text_margin, self.__dimensions.height + 2*self.__text_margin);
		#endregion
		#region Setters/Getters			
				
			/// @method				getText()
			/// @description		Gets the text of the textbox
			/// @return				{String}	The text of the textbox
			self.getText = function()								{ return self.__text; }
			
			/// @method				setText(_text)
			/// @description		Sets the text of the textbox. If set to read only, this will have no effect.
			/// @param				{String}	__text	The text to set
			/// @return				{UITextBox}	self
			self.setText = function(_text) {
				if (!self.__read_only) {
					var _old = self.__text;
					var _new = self.__max_chars == 99999999 ? _text : string_copy(_text, 1, self.__max_chars);
					var _changed = _old != _new;
					if (_changed) {
						self.__text = _new;
						self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
					}
					self.__processCursor(_changed);
				}
				return self;
			}
				
			/// @method				getPlaceholderText()
			/// @description		Gets the placeholder text of the textbox (text that is shown when the textbox is empty)
			/// @return				{String}	The placeholder text of the textbox
			self.getPlaceholderText = function()					{ return self.__placeholder_text; }
			
			/// @method				setPlaceholderText(_text)
			/// @description		Sets the placeholder text of the textbox (text that is shown when the textbox is empty)
			/// @param				{String}	__text	The placeholder text to set
			/// @return				{UITextBox}	self
			self.setPlaceholderText = function(_text)				{ self.__placeholder_text = _text; return self; }
				
			/// @method				getMaxChars()
			/// @description		Gets the maximum character limit for the textbox. If 0, the textbox has no limit.
			/// @return				{Real}	The character limit for the textbox
			self.getMaxChars = function()							{ return self.__max_chars; }
			
			/// @method				setMaxChars(_max_chars)
			/// @description		Sets the maximum character limit for the textbox. If 0, the textbox has no limit.
			/// @param				{Real}	_max_chars	The character limit to set
			/// @return				{UITextBox}	self
			self.setMaxChars = function(_max_chars)	{
				self.__max_chars =  _max_chars <= 0 ? 999999999 : _max_chars;
				if (_max_chars >  0 && string_length(self.__text) > _max_chars)	self.__text = string_copy(self.__text, 1, _max_chars);
				return self;
			}
				
			/// @method				getMaskText()
			/// @description		Gets whether text is masked using a masking character
			/// @return				{Bool}	Whether the text is masked or not
			self.getMaskText = function()							{ return self.__mask_text; }
				
			/// @method				setMaskText(_mask_text)
			/// @description		Sets whether text is masked using a masking character
			/// @param				{Bool}	_mask_text	Whether the text is masked or not
			/// @return				{UITextBox}	self
			self.setMaskText = function(_mask_text)					{ self.__mask_text = _mask_text; return self; }
				
			/// @method				getMaskChar()
			/// @description		Gets the character used to mask text
			/// @return				{String}	The character used to mask
			self.getMaskChar = function()							{ return self.__mask_char; }
				
			/// @method				setMaskChar(_mask_char)
			/// @description		Sets the character used to mask text
			/// @param				{String}	_mask_char	The character to use to mask
			/// @return				{UITextBox}	self
			self.setMaskChar = function(_mask_char)					{ self.__mask_char = _mask_char; return self; }
				
			/// @method				getMultiline()
			/// @description		Returns whether the textbox is multi-line or not.
			/// @return				{Bool}	Whether the textbox is multiline or not
			self.getMultiline = function()							{ return self.__multiline; }
				
			/// @method				setMultiline(_multiline)
			/// @description		Sets whether the textbox is multi-line or not.
			/// @param				{Bool}	_multiline	Whether to set the textbox to multiline or not
			/// @return				{UITextBox}	self
			self.setMultiline = function(_multiline)					{ self.__multiline = _multiline; return self; }
				
			/// @method				getCursorPos()
			/// @description		Returns the cursor position (in characters)
			/// @return				{Real}	the cursor position
			self.getCursorPos = function()							{ return self.__cursor_pos; }
				
			/// @method				setCursorPos(_pos)
			/// @description		Sets the cursor position (in characters)
			/// @param				{Real}	_pos	The cursor position
			/// @return				{UITextBox}	self
			self.setCursorPos = function(_pos)						{ self.__cursor_pos = _pos; return self; }
				
			/// @method				getCurrentlyEditing()
			/// @description		Returns whether the textbox is being edited or not
			/// @return				{Bool}	Whether the textbox is being edited or not
			self.getCurrentlyEditing = function()					{ return global.__gooey_manager_active.__textbox_editing_ref == self; }
				
			/// @method				setCurrentlyEditing(_edit)
			/// @description		Sets whether the textbox is being edited or not. Will only set if the textbox is not set to read only.
			/// @param				{Bool}	_edit	Whether the textbox is being edited
			/// @return				{UITextBox}	self
			self.setCurrentlyEditing = function(_edit) {
				if (!self.__read_only && _edit) {
					global.__gooey_manager_active.__textbox_editing_ref = self;
				}
				return self;
			}
				
			/// @method				getReadOnly()
			/// @description		Returns whether the textbox is read-only or not
			/// @return				{Bool}	Whether the textbox is read-only or not
			self.getReadOnly = function()							{ return self.__read_only; }
				
			/// @method				setReadOnly(_read_only)
			/// @description		Sets whether the textbox is read-only or not
			/// @param				{Bool}	_read_only	Whether the textbox is the textbox is read-only
			/// @return				{UITextBox}	self
			self.setReadOnly = function(_read_only)					{ self.__read_only = _read_only; return self; }
				
			/// @method				getAllowUppercaseLetters()
			/// @description		Returns whether uppercase letters are allowed in the textbox
			/// @return				{Bool}	Whether uppercase letters are allowed
			self.getAllowUppercaseLetters = function()				{ return self.__allow_uppercase_letters; }
				
			/// @method				setAllowUppercaseLetters(_allow_uppercase_letters)
			/// @description		Sets whether uppercase letters are allowed in the textbox
			/// @param				{Bool}	_allow_uppercase_letters	Whether uppercase letters are allowed
			/// @return				{UITextBox}	self
			self.setAllowUppercaseLetters = function(_allow_uppercase_letters)			{ self.__allow_uppercase_letters = _allow_uppercase_letters; return self; }
				
			/// @method				getAllowLowercaseLetters()
			/// @description		Returns whether lowercase letters are allowed in the textbox
			/// @return				{Bool}	Whether lowercase letters are allowed
			self.getAllowLowercaseLetters = function()				{ return self.__allow_lowercase_letters; }
				
			/// @method				setAllowLowercaseLetters(_allow_lowercase_letters)
			/// @description		Sets whether lowercase letters are allowed in the textbox
			/// @param				{Bool}	_allow_lowercase_letters	Whether lowercase letters are allowed
			/// @return				{UITextBox}	self
			self.setAllowLowercaseLetters = function(_allow_lowercase_letters)			{ self.__allow_lowercase_letters = _allow_lowercase_letters; return self; }
				
			/// @method				getAllowSpaces()
			/// @description		Returns whether spaces are allowed in the textbox
			/// @return				{Bool}	Whether spaces are allowed
			self.getAllowSpaces = function()						{ return self.__allow_spaces; }
				
			/// @method				setAllowSpaces(_allow_spaces)
			/// @description		Sets whether spaces are allowed in the textbox
			/// @param				{Bool}	_allow_spaces	Whether spaces are allowed
			/// @return				{UITextBox}	self
			self.setAllowSpaces = function(_allow_spaces)			{ self.__allow_spaces = _allow_spaces; return self; }
				
			/// @method				getAllowDigits()
			/// @description		Returns whether digits are allowed in the textbox
			/// @return				{Bool}	Whether digits are allowed
			self.getAllowDigits = function()						{ return self.__allow_digits; }
				
			/// @method				setAllowDigits(_allow_digits)
			/// @description		Sets whether digits are allowed in the textbox
			/// @param				{Bool}	_allow_digits	Whether digits are allowed
			/// @return				{UITextBox}	self
			self.setAllowDigits = function(_allow_digits)			{ self.__allow_digits = _allow_digits; return self; }
				
			/// @method				getAllowSymbols()
			/// @description		Returns whether symbols are allowed in the textbox
			/// @return				{Bool}	Whether symbols are allowed
			self.getAllowSymbols = function()						{ return self.__allow_symbols; }
				
			/// @method				setAllowSymbols(_allow_symbols)
			/// @description		Sets whether symbols are allowed in the textbox. The specific symbols allowed can be set with the setSymbolsAllowed method.
			/// @param				{Bool}	_allow_symbols	Whether symbols are allowed
			/// @return				{UITextBox}	self
			self.setAllowSymbols = function(_allow_symbols)			{ self.__allow_symbols = _allow_symbols; return self; }
				
			/// @method				getAllowCursorMouse()
			/// @description		Returns whether mouse cursor navigation is allowed
			/// @return				{Bool}	Whether mouse cursor navigation is allowed
			self.getAllowCursorMouse = function()					{ return self.__allow_cursor_mouse; }
				
			/// @method				setAllowCursorMouse(_allow_cursor_mouse)
			/// @description		Sets whether mouse cursor navigation is allowed
			/// @param				{Bool}	_allow_cursor_mouse	Whether mouse cursor navigation is allowed
			/// @return				{UITextBox}	self
			self.setAllowCursorMouse = function(_allow_cursor_mouse)	{ self.__allow_cursor_mouse = _allow_cursor_mouse; return self; }
				
			/// @method				getAllowCursorKeyboard()
			/// @description		Returns whether keyboard cursor navigation is allowed
			/// @return				{Bool}	Whether keyboard cursor navigation is allowed
			self.getAllowCursorKeyboard = function()					{ return self.__allow_cursor_keyboard; }
				
			/// @method				setAllowCursorKeyboard(_allow_cursor_keyboard)
			/// @description		Sets whether keyboard cursor navigation is allowed
			/// @param				{Bool}	_allow_cursor_keyboard	Whether keyboard cursor navigation is allowed
			/// @return				{UITextBox}	self
			self.setAllowCursorKeyboard = function(_allow_cursor_keyboard)	{ self.__allow_cursor_keyboard = _allow_cursor_keyboard; return self; }
				
			/// @method				getSymbolsAllowed()
			/// @description		Returns the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
			/// @return				{String}	The list of allowed symbols
			self.getSymbolsAllowed = function()					{ return self.__symbols_allowed; }
				
			/// @method				setSymbolsAllowed(_symbols)
			/// @description		Sets the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
			/// @param				{String}	_symbols	The list of allowed symbols
			/// @return				{UITextBox}	self
			self.setSymbolsAllowed = function(_symbols)	{ self.__symbols_allowed = _symbols; return self; }
				
			/// @method				getTextAnchor()
			/// @description		Returns the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
			/// @return				{Enum}	The text anchor
			self.getTextAnchor = function()					{ return self.__text_anchor; }
				
			/// @method				setTextAnchor(_anchor)
			/// @description		Sets the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
			/// @param				{Enum}	_anchor		The desired text anchor
			/// @return				{UITextBox}	self
			self.setTextAnchor = function(_anchor)	{ self.__text_anchor = _anchor; return self; }
				
			/// @method				getTextFormat()
			/// @description		Gets the text format for the textbox
			/// @return				{String}	the Scribble text format used for the textbox
			self.getTextFormat = function()							{ return self.__text_format; }
				
			/// @method				setTextFormat(_format)
			/// @description		Sets the text format for the textbox
			/// @param				{String}	_format	the Scribble text format used for the textbox
			/// @return				{UITextBox}	self
			self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
			/// @method				getTextMargin()
			/// @description		Gets the text margin for the text inside the textbox
			/// @return				{Real}	the margin for the text inside the textbox
			self.getTextMargin = function()							{ return self.__text_margin; }
				
			/// @method				setTextMargin(_margin)
			/// @description		Sets the text margin for the text inside the textbox
			/// @param				{Real}	_margin		the margin for the text inside the textbox
			/// @return				{UITextBox}	self
			self.setTextMargin = function(_margin)					{ self.__text_margin = _margin; return self; }
				
		#endregion
		#region Methods
				
			/// @method				clearText()
			/// @description		clears the TextBox text
			/// @return				{UITextBox}	self
			self.clearText= function() {
				self.setText("");
				self.__cursor_pos = -1;
			}
				
			self.__processCursor = function(_text_change) {
				if (_text_change) {
					if (keyboard_lastkey == vk_backspace)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : max(0, self.__cursor_pos-1);
					else if (keyboard_lastkey == vk_delete)	keyboard_lastkey = vk_nokey;
					else if (keyboard_lastkey != vk_delete)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos+1;
				}
				else {									
					if (keyboard_lastkey == vk_home)		self.__cursor_pos = 0;
					else if (keyboard_lastkey == vk_end)	self.__cursor_pos = -1;
					else if (keyboard_lastkey == vk_left) {
						var _n = string_length(self.__text);
						if (keyboard_check(vk_control) && self.__cursor_pos != 0)	{
							do {
								self.__cursor_pos = self.__cursor_pos == -1 ? _n-1 : self.__cursor_pos - 1;
							}
							until (self.__cursor_pos == 0 || string_char_at(self.__text, self.__cursor_pos) == " ");
								
						}
						else {
							self.__cursor_pos = (self.__cursor_pos == -1 ? _n-1 : max(self.__cursor_pos-1, 0));
						}
						keyboard_lastkey = vk_nokey;
					}
					else if (keyboard_lastkey == vk_right) {
						var _n = string_length(self.__text);
						if (keyboard_check(vk_control) && self.__cursor_pos != -1)	{
							do {
								self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos + 1;
								if (self.__cursor_pos == _n) self.__cursor_pos = -1;
							}
							until (self.__cursor_pos == -1 || string_char_at(self.__text, self.__cursor_pos) == " ");								
						}
						else {
							if (self.__cursor_pos >= 0) self.__cursor_pos = ( self.__cursor_pos == _n-1 ? -1 : self.__cursor_pos+1 );						
						}
						keyboard_lastkey = vk_nokey;
					}
				}
			}
				
			self.__draw = function() {
				// Clean the click command
				if ((keyboard_check_pressed(vk_enter) && !self.__multiline) && global.__gooey_manager_active.__textbox_editing_ref == self && !self.__read_only) {
					global.__gooey_manager_active.__textbox_editing_ref = noone;
					self.__cursor_pos = -1;
					keyboard_string = "";
				}
					
				var _x = self.__dimensions.x;
				var _y = self.__dimensions.y;
				var _width = self.__dimensions.width * global.__gooey_manager_active.getScale();					
				var _height = self.__dimensions.height * global.__gooey_manager_active.getScale();
															
				var _text_to_display = (self.__text == "" && global.__gooey_manager_active.__textbox_editing_ref != self) ? self.__placeholder_text : (self.__mask_text ? string_repeat(self.__mask_char, string_length(self.__text)) : self.__text);
				var _cursor = (global.__gooey_manager_active.__textbox_editing_ref == self ? "[blink][c_gray]|[/blink]"+self.getTextFormat() : "");
				var _text_with_cursor = self.__cursor_pos == -1 ? _text_to_display + _cursor : string_copy(_text_to_display, 1, self.__cursor_pos)+_cursor+string_copy(_text_to_display, self.__cursor_pos+1, string_length(_text_to_display));
					
				var _n = max(1, string_length(_text_to_display));
				var _avg_width = UI_TEXT_RENDERER(self.__text_format + "e").get_width();
				var _letter_height = UI_TEXT_RENDERER(self.__text_format + "|").get_height();
				var _s = UI_TEXT_RENDERER(self.__text_format + _text_with_cursor);
										
				// Fix width
				var _offset = max(0, _s.get_width() - _width);
					
				if (self.__multiline) {
					_s.wrap(_width - 2*self.__text_margin);						
				}
				else {						
					_height = _letter_height + 2*self.__text_margin;
					self.__dimensions.height = _height * global.__gooey_manager_active.getScale();
				}
					
				if (_offset > 0 && self.__cursor_pos != -1) {
					var _test = UI_TEXT_RENDERER(string_copy(_text_to_display, 1, self.__cursor_pos)).get_width();
					var _cursor_left_of_textbox = (_test < _offset);
					while (_cursor_left_of_textbox) {
						_offset -= 2*_avg_width;
						_cursor_left_of_textbox = (_test < _offset);
					}
				}
					
					
				if (sprite_exists(self.__sprite)) draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					
				if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(_width, _height);
				surface_set_target(self.__surface_id);
				draw_clear_alpha(c_black, 0);
				_s.draw(self.__text_margin - _offset, self.__text_margin);
				surface_reset_target();
				draw_surface(self.__surface_id, _x, _y);					
			}
			self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK] && global.__gooey_manager_active.__textbox_editing_ref != self)  {
					if (global.__gooey_manager_active.__textbox_editing_ref != noone)	global.__gooey_manager_active.__textbox_editing_ref.__cursor_pos = -1;
					keyboard_string = self.__cursor_pos == -1 ? self.__text : string_copy(self.__text, 1, self.__cursor_pos);
					global.__gooey_manager_active.__textbox_editing_ref = self;
					self.__callbacks[UI_EVENT.LEFT_CLICK]();
				}
					
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
				_arr[UI_EVENT.LEFT_CLICK] = false;
				self.__generalBuiltInBehaviors(_arr);
			}
		#endregion
		
		self.__register();
		return self;
	}
	
#endregion
