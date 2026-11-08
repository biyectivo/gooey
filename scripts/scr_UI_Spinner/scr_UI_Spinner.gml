/// @feather ignore all
#region UISpinner
	
	/// @constructor	UISpinner(_id, _x, _y, _option_array, _sprite_base, _sprite_button_arrow_left, _sprite_button_arrow_right, _width, _height, [_initial_idx=0], [_relative_to=UI_DEFAULT_ANCHOR_POINT])
	/// @extends		UIOptionGroup
	/// @description	A Spinner widget, clickable UI widget that lets the user toggle through a list of values. Extends UIOptionGroup as it provides the same functionality with different interface.
	/// @param			{String}			_id					The Dropdown's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x					The x position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y					The y position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Array<String>}		_option_array		An array with at least one string that contains the text for each of the options
	/// @param			{Asset.GMSprite}	_sprite_base		The sprite ID to use for rendering the background of the currently selected value
	/// @param			{Asset.GMSprite}	_sprite_button_arrow_left	The sprite ID to use for rendering the button of the left arrow
	/// @param			{Asset.GMSprite}	_sprite_button_arrow_right	The sprite ID to use for rendering the button of the right arrow
	/// @param			{Asset.GMSprite}	_width				The total width of the control
	/// @param			{Asset.GMSprite}	_height				The total height of the control
	/// @param			{Real}				[_initial_idx]		The initial selected index of the Dropdown list (default=0, the first option)
	/// @param			{Enum}				[_relative_to]		The position relative to which the Dropdown will be drawn. By default, uses UI_DEFAULT_ANCHOR_POINT macro in the config (top left if not changed) <br>
	///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UIDropdown}							self
	function UISpinner(_id, _x, _y, _option_array, _sprite_base, _sprite_button_arrow_left, _sprite_button_arrow_right, _width, _height, _initial_idx=0, _relative_to=UI_DEFAULT_ANCHOR_POINT) : UIOptionGroup(_id, _x, _y, _option_array, _sprite_base, _initial_idx, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.SPINNER;
			self.__wrap = true;
			self.setDimensions(_x, _y, _width, _height);				
			self.__control = self.add(new UIGroup(self.__ID+"_SpinnerGroup", 0, 0, _width, _height, -1, UI_RELATIVE_TO.TOP_LEFT));
			self.__grid = self.__control.add(new UIGrid(self.__ID+"_SpinnerGroup_Grid", 1, 3));				
			var _lw = sprite_exists(_sprite_button_arrow_left) ? sprite_get_width(_sprite_button_arrow_left)/_width : 0;
			var _rw = sprite_exists(_sprite_button_arrow_right) ? sprite_get_width(_sprite_button_arrow_right)/_width : 0;
			var _cw = 1 - _lw - _rw;
			self.__grid.setColumnProportions([_lw, _cw, _rw]);
			self.__button_left = self.__grid.addToCell(new UIButton(self.__ID+"_SpinnerGroup_ButtonLeft", 0, 0, 0, 0, "", _sprite_button_arrow_left, UI_RELATIVE_TO.TOP_LEFT), 0, 0);
			self.__button_left.setInheritWidth(true);
			self.__button_left.setInheritHeight(true);
			self.__button_right = self.__grid.addToCell(new UIButton(self.__ID+"_SpinnerGroup_ButtonRight", 0, 0, 0, 0, "", _sprite_button_arrow_right, UI_RELATIVE_TO.TOP_LEFT), 0, 2);
			self.__button_right.setInheritWidth(true);
			self.__button_right.setInheritHeight(true);
			self.__button_text = self.__grid.addToCell(new UIButton(self.__ID+"_SpinnerGroup_Text", 0, 0, 0, 0, "", _sprite_base, UI_RELATIVE_TO.MIDDLE_CENTER), 0, 1);
			self.__button_text.setText(self.getOptionRawText());
			self.__button_text.setTextMouseover(self.getOptionRawText());
			self.__button_text.setTextClick(self.getOptionRawText());
			self.__button_text.setInheritWidth(true);
			self.__button_text.setInheritHeight(true);
			self.__button_text.setBinding(self, "getOptionRawText");
			var _spinner = self;
			self.__button_left.setCallback(UI_EVENT.LEFT_RELEASE, method({spinner: _spinner}, function() {
				var _n = array_length(spinner.__option_array_unselected);
				if (_n == 0)	return;
				if (!spinner.__wrap && spinner.getIndex() <= 0)	return;
				spinner.setIndex((spinner.getIndex() - 1 + _n) % _n);
			}));
			self.__button_right.setCallback(UI_EVENT.LEFT_RELEASE, method({spinner: _spinner}, function() {
				var _n = array_length(spinner.__option_array_unselected);
				if (_n == 0)	return;
				if (!spinner.__wrap && spinner.getIndex() >= _n - 1)	return;
				spinner.setIndex((spinner.getIndex() + 1) % _n);
			}));				
				
		#endregion
		#region Setters/Getters			
			/// @method				getButtonLeft()
			/// @description		Gets the left button of the Spinner control
			/// @return				{UIButton}	The left button
			self.getButtonLeft = function()				{ return self.__button_left; }
			
			/// @method				getButtonRight()
			/// @description		Gets the right button of the Spinner control
			/// @return				{UIButton}	The right button
			self.getButtonRight = function()				{ return self.__button_right; }
				
			/// @method				getButtonText()
			/// @description		Gets the text button of the Spinner control
			/// @return				{UIButton}	The text button
			self.getButtonText = function()				{ return self.__button_text; }
				
			/// @method				getGrid()
			/// @description		Gets the UIGrid of the Spinner control
			/// @return				{UIGrid}	The grid
			self.getGrid = function()				{ return self.__grid; }
				
		#endregion
		#region Methods
			/// @method				getWrap()
			/// @description		Gets whether the arrows wrap around at the ends of the option list (default: true)
			/// @return				{Bool}	whether the Spinner wraps
			self.getWrap = function()	{ return self.__wrap; }
			
			/// @method				setWrap(_wrap)
			/// @description		Sets whether the arrows wrap around at the ends of the option list
			/// @param				{Bool}	_wrap	whether the Spinner wraps
			/// @return				{UISpinner}	self
			self.setWrap = function(_wrap)	{ self.__wrap = _wrap; return self; }
			
			self.__draw = function() {
				self.setDimensions();				
			}
			//self.__generalBuiltInBehaviors = method(self, __UIWidget.__builtInBehavior);
			self.__builtInBehavior = function() {					
				var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
				self.__generalBuiltInBehaviors(_arr);
			}
		#endregion
		
		// Do not register since it extends UIOptionGroup and that one already registers
		//self.__register();
		return self;
	}
	
#endregion
	