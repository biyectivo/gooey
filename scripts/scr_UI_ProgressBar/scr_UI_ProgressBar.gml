/// @feather ignore all
#region UIProgressBar
		
	/// @constructor	UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, [_orientation=UI_ORIENTATION.HORIZONTAL], [_relative_to=UI_DEFAULT_ANCHOR_POINT])
	/// @extends		UIWidget
	/// @description	A UIProgressBar widget, that allows the user to select a value from a range by dragging, clicking or scrolling
	/// @param			{String}			_id					The UIProgressBar's name, a unique string ID. If the specified name is taken, the UIProgressBar will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x					The x position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y					The y position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter	
	/// @param			{Asset.GMSprite}	_sprite_base		The sprite ID to use for rendering the UIProgressBar base
	/// @param			{Asset.GMSprite}	_sprite_progress	The sprite ID to use for rendering the UIProgressBar handle
	/// @param			{Real}				_value				The initial value of the UIProgressBar
	/// @param			{Real}				_min_value			The minimum value of the UIProgressBar
	/// @param			{Real}				_max_value			The maximum value of the UIProgressBar
	/// @param			{Enum}				[_orientation]		The orientation of the UIProgressBar, according to UI_ORIENTATION. By default: HORIZONTAL
	/// @param			{Enum}				[_relative_to]		The position relative to which the UIProgressBar will be drawn. By default, uses UI_DEFAULT_ANCHOR_POINT macro in the config (top left if not changed) <br>
	///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UIProgressBar}							self
	function UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, _orientation=UI_ORIENTATION.HORIZONTAL, _relative_to=UI_DEFAULT_ANCHOR_POINT) : __UIWidget(_id, _x, _y, 0, 0, _sprite_base, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.PROGRESSBAR;
			self.__sprite_base = _sprite_base;
			self.__sprite_progress = _sprite_progress;
			self.__sprite_repeat_remaining_progress = noone;
			self.__image_repeat_remaining_progress = 0;
			self.__image_base = 0;
			self.__image_progress = 0;
			self.__image_progress_blend = c_white;
			self.__image_progress_alpha = 1;
			self.__sprite_progress_anchor = _orientation==UI_ORIENTATION.HORIZONTAL ? {x: 0, y: 0} : {x: 0, y: sprite_exists(_sprite_progress) ? sprite_get_height(_sprite_progress) : 0};
			self.__text_value_anchor = {x: 0, y: 0};
			self.__value = _value;
			self.__min_value = _min_value;
			self.__max_value = _max_value;
			self.__show_value = false;
			self.__prefix = "";
			self.__suffix = "";
			self.__text_format = "";
			self.__render_progress_behavior = UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL;
			self.__progress_repeat_unit = 1;
			self.__orientation = _orientation;
			
		#endregion
		#region Setters/Getters				
			/// @method				getSpriteBase()
			/// @description		Gets the sprite ID used for the base of the progressbar, that will be drawn behind
			/// @return				{Asset.GMSprite}	The sprite ID used for the base of the progressbar.
			static getSpriteBase = function()							{ return self.__sprite_base; }
			
			/// @method				setSpriteBase(_sprite)
			/// @description		Sets the sprite to be used for the base of the progessbar, that will be drawn behind 
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIProgressBar}	self
			static setSpriteBase = function(_sprite)					{ self.__sprite_base = _sprite; return self; }
			
			/// @method				getImageBase()
			/// @description		Gets the image index of the sprite used for the base of the progressbar, that will be drawn behind
			/// @return				{Real}	The image index of the sprite used for the base of the progressbar
			static getImageBase = function()							{ return self.__image_base; }
			
			/// @method				setImageBase(_image)
			/// @description		Sets the image index of the sprite used for the base of the progressbar, that will be drawn behind
			/// @param				{Real}	_image	The image index
			/// @return				{UIProgressbar}	self
			static setImageBase = function(_image)					{ self.__image_base = _image; return self; }				
				
			/// @method				getSpriteProgress()
			/// @description		Gets the sprite ID used for rendering progress.
			/// @return				{Asset.GMSprite}	The sprite ID used for rendering progress.
			static getSpriteProgress = function()						{ return self.__sprite_progress; }
			
			/// @method				setSpriteProgress(_sprite)
			/// @description		Sets the sprite to be used for rendering progress.
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIProgressbar}	self
			static setSpriteProgress = function(_sprite)				{ self.__sprite_progress = _sprite; return self; }
				
			/// @method				getSpriteRemainingProgress()
			/// @description		Gets the sprite ID used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
			/// @return				{Asset.GMSprite}	The sprite ID used for rendering the remaining progress.
			static getSpriteRemainingProgress = function()						{ return self.__sprite_repeat_remaining_progress; }
			
			/// @method				setSpriteRemainingProgress(_sprite)
			/// @description		Sets the sprite to be used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIProgressbar}	self
			static setSpriteRemainingProgress = function(_sprite)				{ self.__sprite_repeat_remaining_progress = _sprite; return self; }
			
			/// @method				getImageProgress()
			/// @description		Gets the image index of the sprite used for rendering progress.
			/// @return				{Real}	The image index of the sprite used for rendering progress
			static getImageProgress = function()						{ return self.__image_progress; }
			
			/// @method				setImageProgress(_image)
			/// @description		Sets the image index of the sprite used for rendering progress.
			/// @param				{Real}	_image	The image index
			/// @return				{UIProgressbar}	self
			static setImageProgress = function(_image)					{ self.__image_progress = _image; return self; }		

			/// @method				getImageRemainingProgress()
			/// @description		Gets the image index of the sprite used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
			/// @return				{Real}	The image index of the sprite used for rendering remaining progress
			static getImageRemainingProgress = function()						{ return self.__image_repeat_remaining_progress; }
			
			/// @method				setImageRemainingProgress(_image)
			/// @description		Sets the image index of the sprite used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
			/// @param				{Real}	_image	The image index
			/// @return				{UIProgressbar}	self
			static setImageRemainingProgress = function(_image)					{ self.__image_repeat_remaining_progress = _image; return self; }		
												
			/// @method				getValue()
			/// @description		Gets the value of the progressbar, either via the defined binding or, if undefined, the defined value.<br>
			///						If the value of the defined binding is not boolean, it will return the fixed value set by `setValue` instead.
			/// @return				{Real}	the value of the progressbar
			static getValue = function()	{
				return self.__value;
			}
				
			/// @method				setValue(_value)
			/// @description		Sets the value of the progressbar
			/// @param				{Real}	_value	the value to set for the progressbar
			/// @return				{UIProgressbar}	self
			static setValue = function(_value) { 
				var _old = self.__value;
				var _new = clamp(_value, self.__min_value, self.__max_value);
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
				
			/// @method				getMinValue()
			/// @description		Gets the minimum value of the progressbar
			/// @return				{Real}	the minimum value of the progressbar
			static getMinValue = function()							{ return self.__min_value; }
				
			/// @method				setMinValue(_min_value)
			/// @description		Sets the minimum value of the progressbar
			/// @param				{Real}	_min_value	the value to set
			/// @return				{UIProgressbar}	self
			static setMinValue = function(_min_value)					{ self.__min_value = _min_value; return self; }
				
			/// @method				getMaxValue()
			/// @description		Gets the maximum value of the progressbar
			/// @return				{Real}	the maximum value of the progressbar
			static getMaxValue = function()							{ return self.__max_value; }
				
			/// @method				setMaxValue(_max_value)
			/// @description		Sets the maximum value of the progressbar
			/// @param				{Real}	_max_value	the value to set
			/// @return				{UIProgressbar}	self
			static setMaxValue = function(_max_value)					{ self.__max_value = _max_value; return self; }
				
			/// @method				getOrientation()
			/// @description		Gets the orientation of the progressbar according to UI_ORIENTATION. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
			/// @return				{Enum}	the orientation of the progressbar
			static getOrientation = function()						{ return self.__orientation; }
				
			/// @method				setOrientation(_orientation)
			/// @description		Sets the orientation of the progressbar. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
			/// @param				{Enum}	_orientation	the orientation according to UI_ORIENTATION
			/// @return				{UIProgressbar}	self
			static setOrientation = function(_orientation)			{ self.__orientation = _orientation; return self; }
				
			/// @method				getShowValue()
			/// @description		Gets whether the progressbar renders text for the value
			/// @return				{Bool}	whether the progressbar renders renders text for the value
			static getShowValue = function()						{ return self.__show_value; }
				
			/// @method				setShowValue(_show_value)
			/// @description		Sets whether the progressbar renders text for the value
			/// @param				{Bool}	_show_value	whether the progressbar renders text for the value
			/// @return				{UIProgressbar}	self
			static setShowValue = function(_show_value)				{ self.__show_value = _show_value; return self; }
				
			/// @method				getTextFormat()
			/// @description		Gets the text format for the progressbar text
			/// @return				{String}	the Scribble text format used for the progressbar text
			static getTextFormat = function()							{ return self.__text_format; }
				
			/// @method				setTextFormat(_format)
			/// @description		Sets the text format for the progressbar text
			/// @param				{String}	_format	the Scribble text format used for the progressbar text
			/// @return				{UIProgressbar}	self
			static setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
			/// @method				getPrefix()
			/// @description		Gets the prefix for the progressbar text
			/// @return				{String}	the Scribble prefix used for the progressbar text
			static getPrefix = function()							{ return self.__prefix; }
				
			/// @method				setPrefix(_prefix)
			/// @description		Sets the prefix for the progressbar text
			/// @param				{String}	_prefix	the Scribble prefix used for the progressbar text
			/// @return				{UIProgressbar}	self
			static setPrefix = function(_prefix)					{ self.__prefix = _prefix; return self; }
				
			/// @method				getSuffix()
			/// @description		Gets the suffix for the progressbar text
			/// @return				{String}	the Scribble suffix used for the progressbar text
			static getSuffix = function()							{ return self.__suffix; }
				
			/// @method				setSuffix(_suffix)
			/// @description		Sets the suffix for the progressbar text
			/// @param				{String}	_suffix	the Scribble suffix used for the progressbar text
			/// @return				{UIProgressbar}	self
			static setSuffix = function(_suffix)					{ self.__suffix = _suffix; return self; }
				
			/// @method				getRenderProgressBehavior()
			/// @description		Gets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
			///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
			///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
			///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
			///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
			///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
			/// @return				{Bool}	The image index of the sprite used for the base of the progressbar
			static getRenderProgressBehavior = function()							{ return self.__render_progress_behavior; }
			
			/// @method				setRenderProgressBehavior(_progress_behavior)
			/// @description		Sets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
			///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
			///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
			///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
			///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
			///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
			/// @param				{Enum}	_progress_behavior	The desired rendering behavior of the progressbar
			/// @return				{UIProgressbar}	self
			static setRenderProgressBehavior = function(_progress_behavior)					{ self.__render_progress_behavior = _progress_behavior; return self; }
				
			/// @method				getProgressRepeatUnit()
			/// @description		Gets the value that each repeated progress sprite occurrence represents.<br>
			///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three `(= floor(17/5))` times
			///						(provided the render mode is set to REPEAT using `setRenderProgressBehavior`).
			/// @return				{Real}	The value that each marking represents within the progress bar
			static getProgressRepeatUnit = function()							{ return self.__progress_repeat_unit; }
			
			/// @method				setProgressRepeatUnit(_progress_repeat_unit)
			/// @description		Sets the value that each repeated progress sprite occurrence represents.<br>
			///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three (floor(17/5)) times
			///						(provided the render mode is set to progress repeat using `setRenderProgressRepeat`).				
			/// @param				{Real}	_progress_repeat_unit	The value that each marking represents within the progress bar
			/// @return				{UIProgressbar}	self
			static setProgressRepeatUnit = function(_progress_repeat_unit)					{ self.__progress_repeat_unit = _progress_repeat_unit; return self; }
				
			/// @method				getSpriteProgressAnchor()
			/// @description		Gets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
			///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel)
			///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
			/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
			static getSpriteProgressAnchor = function()						{ return self.__sprite_progress_anchor; }
				
			/// @method				setSpriteProgressAnchor(_anchor_struct)
			/// @description		Sets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
			///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel).
			///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
			/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
			/// @return				{UIProgressbar}	self
			static setSpriteProgressAnchor = function(_anchor_struct)			{ self.__sprite_progress_anchor = _anchor_struct; return self; }
				
			/// @method				getTextValueAnchor()
			/// @description		Gets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
			/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
			static getTextValueAnchor = function()						{ return self.__text_value_anchor; }
				
			/// @method				setTextValueAnchor(_anchor_struct)
			/// @description		Sets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
			/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
			/// @return				{UIProgressbar}	self
			static setTextValueAnchor = function(_anchor_struct)			{ self.__text_value_anchor = _anchor_struct; return self; }
			
						
			
			/// @method				getImageProgressBlend()
			/// @description		Gets the image blend of the progress sprite
			/// @return				{Constant.Color}	The image blend
			static getImageProgressBlend = function()			{ return self.__image_progress_blend; }
			
			/// @method				setImageProgressBlend(_color)
			/// @description		Sets the image blend of the progress sprite
			/// @param				{Constant.Color}	_color	The image blend
			/// @return				{UIWidget}	self
			static setImageProgressBlend = function(_color)		{ self.__image_progress_blend = _color; return self; }
				
			/// @method				getImageProgressAlpha()
			/// @description		Gets the image alpha of the progress sprite
			/// @return				{Real}	The image alpha
			static getImageProgressAlpha = function()			{ return self.__image_progress_alpha; }
			
			/// @method				setImageProgressAlpha(_color)
			/// @description		Sets the image alpha of the progress sprite
			/// @param				{Real}	_alpha	The image alpha
			/// @return				{UIWidget}	self
			static setImageProgressAlpha = function(_alpha)		{ self.__image_progress_alpha = _alpha; return self; }
			

			
			
		#endregion
		#region Methods
				
			static __getProportion = function() {
				var _range = self.__max_value - self.__min_value;
				return _range == 0 ? 0 : clamp((self.__value - self.__min_value) / _range, 0, 1);
			}
			
			self.__draw = function() {
				var _sc = global.__gooey_manager_active.__scale;
				var _x = self.__dimensions.x;
				var _y = self.__dimensions.y;
				var _proportion = self.__getProportion();
				var _width_base =  sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) : 0;
				var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) : 0;
				var _has_progress = sprite_exists(self.__sprite_progress);
				var _has_remaining = sprite_exists(self.__sprite_repeat_remaining_progress);
				var _wp = _has_progress ? sprite_get_width(self.__sprite_progress) : 0;
				var _hp = _has_progress ? sprite_get_height(self.__sprite_progress) : 0;
				var _wr = _has_remaining ? sprite_get_width(self.__sprite_repeat_remaining_progress) : 0;
				var _hr = _has_remaining ? sprite_get_height(self.__sprite_repeat_remaining_progress) : 0;
				var _ax = _x + self.__sprite_progress_anchor.x * _sc;
				var _ay = _y + self.__sprite_progress_anchor.y * _sc;
				var _horizontal = (self.__orientation == UI_ORIENTATION.HORIZONTAL);
				
				if (sprite_exists(self.__sprite_base)) draw_sprite_ext(self.__sprite_base, self.__image_base, _x, _y, _sc, _sc, 0, self.__image_blend, self.__image_alpha);
				
				switch (self.__render_progress_behavior) {
					case UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL:
						if (_has_progress) {
							if (_horizontal)	draw_sprite_part_ext(self.__sprite_progress, self.__image_progress, 0, 0, _wp * _proportion, _hp, _ax, _ay, _sc, _sc, self.__image_blend, self.__image_alpha);
							else				draw_sprite_part_ext(self.__sprite_progress, self.__image_progress, 0, _hp * (1-_proportion), _wp, _hp * _proportion, _ax, _ay - _hp * _proportion * _sc, _sc, _sc, self.__image_blend, self.__image_alpha);
						}
						break;
					case UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT:
						var _unit = max(self.__progress_repeat_unit, 0.000001);
						var _times = floor(self.__value / _unit);
						var _max_times = floor(self.__max_value / _unit);
						for (var _i=0; _i<_max_times; _i++) {
							var _filled = (_i < _times);
							var _spr = _filled ? self.__sprite_progress : self.__sprite_repeat_remaining_progress;
							if (!sprite_exists(_spr))	continue;
							var _img = _filled ? self.__image_progress : self.__image_repeat_remaining_progress;
							var _step_w = (_filled ? _wp : _wr) * _sc;
							var _step_h = (_filled ? _hp : _hr) * _sc;
							if (_horizontal)	draw_sprite_ext(_spr, _img, _ax + _i * _step_w, _ay, _sc, _sc, 0, self.__image_blend, self.__image_alpha);
							else				draw_sprite_ext(_spr, _img, _ax, _ay - _i * _step_h, _sc, _sc, 0, self.__image_blend, self.__image_alpha);
						}
						break;
					case UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH:
						if (_has_progress) {
							if (_horizontal)	draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, _ax, _ay, _proportion * _wp * _sc, _hp * _sc, self.__image_blend, self.__image_alpha);
							else				draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, _ax, _ay - _hp * _proportion * _sc, _wp * _sc, _hp * _proportion * _sc, self.__image_blend, self.__image_alpha);
						}
						break;
				}
				
				self.setDimensions(,, _width_base, _height_base);
				if (self.__show_value) {
					UI_TEXT_RENDERER(self.__text_format+self.__prefix+string(self.getValue())+self.__suffix).draw(self.__dimensions.x + self.__text_value_anchor.x, self.__dimensions.y + self.__text_value_anchor.y);
				}
			}
			self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
			self.__builtInBehavior = function() {
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);					
				self.__generalBuiltInBehaviors(_arr);
			}
		#endregion
		
		self.__register();
		return self;
	}
	
#endregion
