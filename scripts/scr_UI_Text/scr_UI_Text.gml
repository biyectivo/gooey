/// @feather ignore all
#region UIText
	
	/// @constructor	UIText(_id, _x, _y, _text, [_relative_to=UI_DEFAULT_ANCHOR_POINT])
	/// @extends		UIWidget
	/// @description	A Text widget, which renders a Scribble text to the screen
	/// @param			{String}			_id				The Text's name, a unique string ID. If the specified name is taken, the Text will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the Text, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the Text, **relative to its parent**, according to the _relative_to parameter		
	/// @param			{String}			_text			The text to display for the Button
	/// @param			{Enum}				[_relative_to]	The position relative to which the Text will be drawn. By default, uses UI_DEFAULT_ANCHOR_POINT macro in the config (top left if not changed) <br>
	///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UIText}							self
	function UIText(_id, _x, _y, _text, _relative_to=UI_DEFAULT_ANCHOR_POINT) : __UIWidget(_id, _x, _y, 0, 0, -1, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.TEXT;
			self.__text_format = "";
			self.__text_format_mouseover = "";
			self.__text_format_click = "";
			self.__text = _text;
			self.__text_mouseover = _text;
			self.__text_click = _text;
			self.__border_color = -1;
			self.__background_color = -1;
			self.__max_width = 0;
			self.__typist = undefined;
			self.__background_alpha = 1;
			self.__source_blendmode = bm_src_alpha;
			self.__dest_blendmode = bm_inv_src_alpha;
			self.__force_blendmode = false;
			self.__interactable = false;
		#endregion
		#region Setters/Getters
			/// @method				getRawText()
			/// @description		Gets the text of the UIText, without Scribble formatting tags.
			///	@return				{String}	The text, without Scribble formatting tags.			
			static getRawText = function()						{ return UI_TEXT_RENDERER(self.__text).get_text(); }
			
			/// @method				getText()
			/// @description		Gets the Scribble text string of the UIText, either via the defined binding or, if undefined, the defined text.
			///	@return				{String}	The Scribble text string of the button.
			static getText = function() {
				return self.__text;
			}
			
			/// @method				setText(_text,  [_set_all_states])
			/// @description		Sets the Scribble text string of the UIText.
			/// @param				{String}	_text	The Scribble string to assign to the UIText.			
			/// @param				{Bool}		[_set_all_states]		whether to set all states at the same time, default=false
			/// @return				{UIText}	self
			static setText = function(_text, _set_all_states=false)	{
				self.__text = _text;
				if (!is_undefined(self.__binding)) {
					self.__updateBoundVariable(_text);
				}
				if (_set_all_states) {
					self.setTextMouseover(_text);
					self.setTextClick(_text);
				}
				return self;
			}
						
			/// @method				getRawTextMouseover()
			/// @description		Gets the text of the UIText when mouseovered, without Scribble formatting tags.
			///	@return				{String}	The text, without Scribble formatting tags.			
			static getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
			/// @method				getTextMouseover()
			/// @description		Gets the Scribble text string of the UIText when mouseovered.
			///	@return				{String}	The Scribble text string of the UIText when mouseovered.
			static getTextMouseover = function()					{ return self.__text_mouseover; }
			
			/// @method				setTextMouseover(_text)
			/// @description		Sets the Scribble text string of the UIText when mouseovered.
			/// @param				{String}	_text_mouseover	The Scribble string to assign to the UIText when mouseovered.
			/// @return				{UIText}	self
			static setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
			
			/// @method				getRawTextClick()
			/// @description		Gets the text of the UIText when clicked, without Scribble formatting tags.
			///	@return				{String}	The text, without Scribble formatting tags.			
			static getRawTextClick = function()					{ return UI_TEXT_RENDERER(self.__text_click).get_text(); }
			
			/// @method				getTextClick()
			/// @description		Gets the Scribble text string of the UIText when clicked.
			///	@return				{String}	The Scribble text string of the UIText when clicked.
			static getTextClick = function()						{ return self.__text_click; }
			
			/// @method				setTextClick(_text)
			/// @description		Sets the Scribble text string of the UIText when clicked.
			/// @param				{String}	_text_click	The Scribble string to assign to the UIText when clicked.
			/// @return				{UIText}	self
			static setTextClick = function(_text_click)			{ self.__text_click = _text_click; return self; }
			
			/// @method				getBorderColor()
			/// @description		Gets the border color of the text, or -1 if invisible
			///	@return				{Constant.Colour}	The border color or -1
			static getBorderColor = function()					{ return self.__border_color; }
			
			/// @method				setBorderColor(_color)
			/// @description		Sets the border color of the text to a color, or unsets it if it's -1
			/// @param				{Constant.Color}	_color	The color constant, or -1
			/// @return				{UIText}	self
			static setBorderColor = function(_color)			{ self.__border_color = _color; return self; }
			
			/// @method				getBackgroundColor()
			/// @description		Gets the background color of the text, or -1 if invisible
			///	@return				{Constant.Colour}	The background color or -1
			static getBackgroundColor = function()				{ return self.__background_color; }
			
			/// @method				setBackgroundColor(_color)
			/// @description		Sets the background color of the text to a color, or unsets it if it's -1
			/// @param				{Constant.Color}	_color	The color constant, or -1
			/// @return				{UIText}	self
			static setBackgroundColor = function(_color)			{ self.__background_color = _color; return self; }
				
			/// @method				getBackgroundAlpha()
			/// @description		Gets the background alpha of the text background
			///	@return				{Real}	The background alpha
			static getBackgroundAlpha = function()				{ return self.__background_alpha; }
			
			/// @method				setBackgroundAlpha(_alpha)
			/// @description		Sets the background alpha of the text background
			/// @param				{Real}	_alpha	The alpha value
			/// @return				{UIText}	self
			static setBackgroundAlpha = function(_alpha)			{ self.__background_alpha = _alpha; return self; }
			
			/// @method				getTypist()
			/// @description		Gets the text renderer typist
			///	@return				{Any}	The typist
			static getTypist = function()				{ return self.__typist; }
			
			/// @method				setTypist(_typist)
			/// @description		Sets the text renderer typist
			/// @param				{Any}	_typist	The typist to set
			/// @return				{UIText}	self
			static setTypist = function(_typist)			{ self.__typist = _typist; return self; }
			
				
			/// @method				getMaxWidth()
			/// @description		Gets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
			///	@return				{Real}	The max width, or 0 if unlimited
			static getMaxWidth = function()				{ return self.__max_width; }
			
			/// @method				setMaxWidth(_max_width)
			/// @description		Sets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
			/// @param				{Real}	_max_width	The max width, or 0 if unlimited
			/// @return				{UIText}	self
			static setMaxWidth = function(_max_width)			{ self.__max_width = _max_width; return self; }
			
			/// @method				getSourceBlendmode()
			/// @description		Gets the currently used source blend mode for the UIText. This will be used if parent or panel is set to clip contents, or the force blendmode property is enabled.
			///	@return				{Real}	The blend mode constant being used to render the UIText
			static getSourceBlendmode = function()						{ return self.__source_blendmode; }
			
			/// @method				setSourceBlendmode(_blend_mode_constant)
			/// @description		Gets the currently used source blend mode for the UIText. This will be used if parent or panel is set to clip contents, or the force blendmode property is enabled.
			/// @param				{Real}	_blend_mode_constant	_blend_mode_constant
			static setSourceBlendmode = function(_blend_mode_constant) {
				self.__source_blendmode = _blend_mode_constant;
				return self;
			}
			
			/// @method				getDestBlendmode()
			/// @description		Gets the currently used destination blend mode for the UIText. This will be used if parent or panel is set to clip contents, or the force blendmode property is enabled.
			///	@return				{Real}	The blend mode constant being used to render the UIText
			static getDestBlendmode = function()						{ return self.__dest_blendmode; }
			
			/// @method				setDestBlendmode(_blend_mode_constant)
			/// @description		Gets the currently used destination blend mode for the UIText. This will be used if parent or panel is set to clip contents, or the force blendmode property is enabled.
			/// @param				{Real}	_blend_mode_constant	_blend_mode_constant
			static setDestBlendmode = function(_blend_mode_constant) {
				self.__dest_blendmode = _blend_mode_constant;
				return self;
			}
			
			/// @method				getForceBlendmode()
			/// @description		Gets the force blendmode use property.
			///	@return				{Real}	The blend mode constant being used to render the UIText
			static getForceBlendmode = function()						{ return self.__force_blendmode; }
			
			/// @method				setForceBlendmode(_force)
			/// @description		Sets the currently used destination blend mode for the UIText. This will be used if parent or panel is set to clip contents, or the force blendmode property is enabled.
			/// @param				{Bool}	_force	whether to force blend mode use for rendering this UIText
			static setForceBlendmode = function(_force) {
				self.__force_blendmode = _force;
				return self;
			}
			
			/// @method			getTextFormat()
			/// @description	Gets the value of the Scribble string used for the starting format of the text
			/// @return			{String}	the Scribble format string
			static getTextFormat = function() {
				return self.__text_format;
			}

			/// @method			setTextFormat(_text_format, [_set_all_states])
			/// @description	Sets the value of the Scribble string used for the starting format of the text
			/// @param			{String}	_text_format			the Scribble format string to set
			/// @param			{Bool}		[_set_all_states]		whether to set all states at the same time, default=false
			/// @return			{UIText}	self
			static setTextFormat = function(_text_format, _set_all_states=false) {
				self.__text_format = _text_format;
				if (_set_all_states) {
					self.setTextFormatMouseover(_text_format);
					self.setTextFormatClick(_text_format);
				}
				return self;
			}

			/// @method			getTextFormatMouseover()
			/// @description	Gets the value of the Scribble string used for the starting format of the text mouseover
			/// @return			{String}	the Scribble format string
			static getTextFormatMouseover = function() {
				return self.__text_format_mouseover;
			}

			/// @method			setTextFormatMouseover(_text_format)
			/// @description	Sets the value of the Scribble string used for the starting format of the text mouseover
			/// @param			{String}	_text_format	the Scribble format string to set
			/// @return			{UIText}	self
			static setTextFormatMouseover = function(_text_format) {
				self.__text_format_mouseover = _text_format;
				return self;
			}

			/// @method			getTextFormatClick()
			/// @description	Gets the value of the Scribble string used for the starting format of the text click
			/// @return			{String}	the Scribble format string
			static getTextFormatClick = function() {
				return self.__text_format_click;
			}

			/// @method			setTextFormatClick(_text_format)
			/// @description	Sets the value of the Scribble string used for the starting format of the text click
			/// @param			{String}	_text_format	the Scribble format string to set
			/// @return			{UIText}	self
			static setTextFormatClick = function(_text_format) {
				self.__text_format_click = _text_format;
				return self;
			}

			/// @method			getTextWidth()
			/// @description	Gets the text width of the element.
			///					Note that getDimensions().width will return 0 for UIText elements.
			/// @return			{Real}	the Scribble text width of the text element bbox
			static getTextWidth = function() {
				var _fmt = self.__text_format;
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_fmt =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_format_click : self.__text_format_mouseover;
				}
				var _txt = UI_TEXT_RENDERER(_fmt + self.getText());
				if (self.getMaxWidth() > 0)		_txt.wrap(self.getMaxWidth());
				return _txt.get_width();
			}
			
			/// @method			getTextHeight()
			/// @description	Gets the text height of the element.
			///					Note that getDimensions().height will return 0 for UIText elements.
			/// @return			{Real}	the Scribble text height of the text element bbox
			static getTextHeight = function() {
				var _fmt = self.__text_format;
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_fmt =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_format_click : self.__text_format_mouseover;
				}
				var _txt = UI_TEXT_RENDERER(_fmt + self.getText());
				if (self.getMaxWidth() > 0)		_txt.wrap(self.getMaxWidth());
				return _txt.get_height();
			}
			
		#endregion
		#region Methods
			self.__draw = function() {
				var _x = self.__dimensions.x;
				var _y = self.__dimensions.y;					
										
				var _text = self.getText();
				var _scale = global.__gooey_manager_active.__scale_tag;
										
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_text =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
				}
				
				var _fmt = self.__text_format;
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_fmt =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_format_click : self.__text_format_mouseover;
				}
				
				if (_scale != self.__ds_tag || _fmt != self.__ds_fmt || _text != self.__ds_text) {
					self.__ds_tag = _scale;
					self.__ds_fmt = _fmt;
					self.__ds_text = _text;
					self.__ds_str = _scale + _fmt + string(_text);
				}
				var _s = UI_TEXT_RENDERER(self.__ds_str);					
				if (self.__max_width > 0)	_s.wrap(self.__max_width);
					
				//self.setDimensions(self.getDimensions().offset_x+_s.get_width(),self.getDimensions().offset_y+_s.get_height(),_s.get_width(), _s.get_height());

				// The rectangle (and the text bounding box it needs) is only computed when there is a background or border to draw
				if (self.__background_color != -1 || self.__border_color != -1) {
					var _x1 = _s.get_left(_x);
					var _x2 = _s.get_right(_x);
					var _y1 = _s.get_top(_y);
					var _y2 = _s.get_bottom(_y);
					if (self.__background_color != -1) {
						var _alpha = draw_get_alpha();
						draw_set_alpha(self.__background_alpha);
						draw_rectangle_color(_x1, _y1, _x2, _y2, self.__background_color, self.__background_color, self.__background_color, self.__background_color, false);
						draw_set_alpha(_alpha);
					}
					if (self.__border_color != -1)		draw_rectangle_color(_x1, _y1, _x2, _y2, self.__border_color, self.__border_color, self.__border_color, self.__border_color, true);
				}

				var _panel = self.getContainingPanel();
				var _panel_clips = (_panel != noone && _panel.__clips_content) || (self.__parent != noone && self.__parent.__clips_content);
				if (self.__force_blendmode || (_panel_clips && self.__background_color == -1)) {
					var _src_bm = gpu_get_blendmode_src();
					var _dest_bm = gpu_get_blendmode_dest();
					gpu_set_blendmode_ext(self.__source_blendmode, self.__dest_blendmode);
					_s.draw(_x, _y, self.__typist);
					gpu_set_blendmode_ext(_src_bm, _dest_bm);
				}
				else {
					_s.draw(_x, _y, self.__typist);
				}
			}
			self.__cull_mode = 1;	// culled by __isCulled (draws only inside its rectangle / text bounding box)
			// Culling: the bounding box of the text as drawn in its regular (non hovered) state, with a margin for Scribble effects (wave, shake...)
			static __isCulled = function(_m) {
				var _d = self.__dimensions;
				// Quick accept: the text bounding box always contains its anchor point, so a visible anchor means a visible text
				if (_d.x >= _m.__cull_x0 && _d.x <= _m.__cull_x1 && _d.y >= _m.__cull_y0 && _d.y <= _m.__cull_y1)	return false;
				var _bb = self.__getTextCullBBox(_m.__scale_tag, self.__text_format, self.__text, self.__max_width);
				return (_d.x + _bb.left - 24 > _m.__cull_x1) || (_d.x + _bb.right + 24 < _m.__cull_x0) || (_d.y + _bb.top - 24 > _m.__cull_y1) || (_d.y + _bb.bottom + 24 < _m.__cull_y0);
			}
			self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
			self.__builtInBehavior = function() {
				if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
				_arr[UI_EVENT.LEFT_CLICK] = false;
				self.__generalBuiltInBehaviors(_arr);
			}
		#endregion
		
		self.__register();
		return self;
	}
	
#endregion