/// @feather ignore all
#region Input provider (input seam)

	/// All pointer/keyboard state used by gooey is read through the functions in this script instead of calling
	/// GameMaker's input functions directly. By default these functions simply forward to GameMaker. You can
	/// install an *input provider* (a struct of callbacks) with `ui_set_input_provider()` to feed gooey with
	/// simulated, recorded, remapped or gamepad-driven input. The automated test-suite uses this to simulate the mouse.
	///
	/// Every callback is optional; missing callbacks fall back to GameMaker's native behavior:
	///   mouse_x(_device)  mouse_y(_device)            -> pointer position in GUI coordinates
	///   mouse_down(_device, _button)                  -> button held
	///   mouse_pressed(_device, _button)               -> button pressed this frame
	///   mouse_released(_device, _button)              -> button released this frame
	///   wheel_up()  wheel_down()                      -> wheel moved this frame
	///   key_down(_key)  key_pressed(_key)             -> keyboard checks
	global.__gooey_input_provider = undefined;

	/// @function					ui_set_input_provider(_provider)
	/// @description				installs an input provider (see the input seam notes in `scr_UI_Input`). Pass `undefined` to restore GameMaker's native input.
	/// @param	{Struct}			_provider	a struct with any of the callbacks `mouse_x, mouse_y, mouse_down, mouse_pressed, mouse_released, wheel_up, wheel_down, key_down, key_pressed`, or `undefined`
	function ui_set_input_provider(_provider) {
		global.__gooey_input_provider = _provider;
	}

	/// @function					ui_get_input_provider()
	/// @description				gets the currently installed input provider
	/// @return	{Struct}			the provider struct, or `undefined` if GameMaker's native input is in use
	function ui_get_input_provider() {
		return global.__gooey_input_provider;
	}

	function __gooey_mouse_x(_device) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "mouse_x"])) return _p.mouse_x(_device);
		return device_mouse_x_to_gui(_device);
	}

	function __gooey_mouse_y(_device) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "mouse_y"])) return _p.mouse_y(_device);
		return device_mouse_y_to_gui(_device);
	}

	function __gooey_mouse_down(_device, _button) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "mouse_down"])) return _p.mouse_down(_device, _button);
		return device_mouse_check_button(_device, _button);
	}

	function __gooey_mouse_pressed(_device, _button) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "mouse_pressed"])) return _p.mouse_pressed(_device, _button);
		return device_mouse_check_button_pressed(_device, _button);
	}

	function __gooey_mouse_released(_device, _button) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "mouse_released"])) return _p.mouse_released(_device, _button);
		return device_mouse_check_button_released(_device, _button);
	}

	function __gooey_wheel_up() {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "wheel_up"])) return _p.wheel_up();
		return mouse_wheel_up();
	}

	function __gooey_wheel_down() {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "wheel_down"])) return _p.wheel_down();
		return mouse_wheel_down();
	}

	function __gooey_key_down(_key) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "key_down"])) return _p.key_down(_key);
		return keyboard_check(_key);
	}

	function __gooey_key_pressed(_key) {
		var _p = global.__gooey_input_provider;
		if (_p != undefined && is_callable(_p[$ "key_pressed"])) return _p.key_pressed(_key);
		return keyboard_check_pressed(_key);
	}

#endregion
