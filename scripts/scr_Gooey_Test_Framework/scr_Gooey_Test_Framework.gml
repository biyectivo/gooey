/// @feather ignore all
/************************************************************************************

	gooey automated test framework

	A tiny xUnit-style framework so the whole library can be tested from inside
	GameMaker (and headlessly from the command line, see tools/run_tests.ps1).

	  var _s = gt_suite("Checkbox");
	  _s.test("toggles", function() { gt_assert_equal(1+1, 2); });

	Assertions throw; the runner catches the exception (as well as ordinary GameMaker
	runtime errors, which are reported as ERROR instead of FAIL) and carries on.

*************************************************************************************/

#macro GT_LOG_PREFIX "[GOOEY-TEST] "

global.__gt = {
	suites: [],
	assertions: 0
};

#region Suite definition

	/// @function GooeyTestSuite(_name)
	function GooeyTestSuite(_name) constructor {
		self.name = _name;
		self.tests = [];
		self.__before_each = undefined;
		self.__after_each = undefined;

		static beforeEach = function(_fn) { self.__before_each = _fn; return self; }
		static afterEach = function(_fn) { self.__after_each = _fn; return self; }
		static test = function(_name, _fn) { array_push(self.tests, {name: _name, fn: _fn, skip: false}); return self; }
		static skip = function(_name, _fn) { array_push(self.tests, {name: _name, fn: _fn, skip: true}); return self; }
	}

	/// @function gt_suite(_name)
	/// @description creates and registers a test suite
	function gt_suite(_name) {
		var _s = new GooeyTestSuite(_name);
		array_push(global.__gt.suites, _s);
		return _s;
	}

#endregion

#region Assertions

	function __gt_stringify(_v) {
		if (is_undefined(_v))	return "undefined";
		if (is_string(_v))		return "\"" + _v + "\"";
		if (is_array(_v) || is_struct(_v)) {
			try { return json_stringify(_v); } catch (_e) { return "<" + typeof(_v) + ">"; }
		}
		if (is_method(_v))		return "<function>";
		return string(_v);
	}

	function __gt_fail(_msg) {
		throw { gt_failure: true, message: _msg };
	}

	function __gt_suffix(_msg) {
		return _msg != "" ? " (" + _msg + ")" : "";
	}

	function gt_equal(_a, _b) {
		if (is_array(_a) && is_array(_b)) {
			if (array_length(_a) != array_length(_b)) return false;
			for (var _i=0, _n=array_length(_a); _i<_n; _i++) if (!gt_equal(_a[_i], _b[_i])) return false;
			return true;
		}
		if (is_struct(_a) && is_struct(_b)) {
			if (_a == _b) return true;
			var _na = variable_struct_get_names(_a), _nb = variable_struct_get_names(_b);
			if (array_length(_na) != array_length(_nb)) return false;
			for (var _i=0, _n=array_length(_na); _i<_n; _i++) {
				if (!variable_struct_exists(_b, _na[_i])) return false;
				if (!gt_equal(variable_struct_get(_a, _na[_i]), variable_struct_get(_b, _na[_i]))) return false;
			}
			return true;
		}
		if (is_undefined(_a) || is_undefined(_b)) return is_undefined(_a) && is_undefined(_b);
		if (is_numeric(_a) && is_numeric(_b)) return _a == _b;
		if (typeof(_a) != typeof(_b)) return false;
		return _a == _b;
	}

	function gt_fail(_msg = "explicit failure") { __gt_fail(_msg); }

	function gt_assert_true(_cond, _msg = "") {
		global.__gt.assertions++;
		if (!_cond) __gt_fail("expected true but got " + __gt_stringify(_cond) + __gt_suffix(_msg));
	}

	function gt_assert_false(_cond, _msg = "") {
		global.__gt.assertions++;
		if (_cond) __gt_fail("expected false but got " + __gt_stringify(_cond) + __gt_suffix(_msg));
	}

	function gt_assert_equal(_actual, _expected, _msg = "") {
		global.__gt.assertions++;
		if (!gt_equal(_actual, _expected)) __gt_fail("expected " + __gt_stringify(_expected) + " but got " + __gt_stringify(_actual) + __gt_suffix(_msg));
	}

	function gt_assert_not_equal(_actual, _unexpected, _msg = "") {
		global.__gt.assertions++;
		if (gt_equal(_actual, _unexpected)) __gt_fail("expected value to differ from " + __gt_stringify(_unexpected) + __gt_suffix(_msg));
	}

	function gt_assert_near(_actual, _expected, _eps = 0.001, _msg = "") {
		global.__gt.assertions++;
		if (!is_numeric(_actual) || is_nan(_actual) || abs(_actual - _expected) > _eps) __gt_fail("expected ~" + string(_expected) + " (+/-" + string(_eps) + ") but got " + __gt_stringify(_actual) + __gt_suffix(_msg));
	}

	function gt_assert_undefined(_v, _msg = "") {
		global.__gt.assertions++;
		if (!is_undefined(_v)) __gt_fail("expected undefined but got " + __gt_stringify(_v) + __gt_suffix(_msg));
	}

	function gt_assert_defined(_v, _msg = "") {
		global.__gt.assertions++;
		if (is_undefined(_v)) __gt_fail("expected a defined value" + __gt_suffix(_msg));
	}

	/// @function gt_assert_throws(_fn, [_msg])
	/// @description asserts that calling _fn raises an exception (of any kind)
	function gt_assert_throws(_fn, _msg = "") {
		global.__gt.assertions++;
		var _threw = false;
		try { _fn(); } catch (_e) { _threw = true; }
		if (!_threw) __gt_fail("expected function to throw" + __gt_suffix(_msg));
	}

	/// @function gt_assert_no_throw(_fn, [_msg])
	/// @description asserts that calling _fn does not raise; useful to pin down crashes
	function gt_assert_no_throw(_fn, _msg = "") {
		global.__gt.assertions++;
		try { _fn(); }
		catch (_e) {
			var _m = (is_struct(_e) && variable_struct_exists(_e, "message")) ? _e.message : string(_e);
			__gt_fail("unexpected exception: " + _m + __gt_suffix(_msg));
		}
	}

#endregion

#region Simulated input

	/// @function GooeyMockInput()
	/// @description simulated mouse/keyboard to drive the UI deterministically. `install()` registers it with `ui_set_input_provider()`.
	function GooeyMockInput() constructor {
		self.x = 0;
		self.y = 0;
		self.down = array_create(6, false);			// indexed by mb_left (1), mb_right (2), mb_middle (3)
		self.pressed = array_create(6, false);
		self.released = array_create(6, false);
		self.wheel = 0;								// +1 wheel up, -1 wheel down (one frame)
		self.keys_down = {};
		self.keys_pressed = {};

		self.install = function() {
			ui_set_input_provider(self);
			return self;
		}
		// --- provider callbacks (see scr_UI_Input)
		self.mouse_x = function(_d) { return self.x; }
		self.mouse_y = function(_d) { return self.y; }
		self.mouse_down = function(_d, _b) { return self.down[_b]; }
		self.mouse_pressed = function(_d, _b) { return self.pressed[_b]; }
		self.mouse_released = function(_d, _b) { return self.released[_b]; }
		self.wheel_up = function() { return self.wheel > 0; }
		self.wheel_down = function() { return self.wheel < 0; }
		self.key_down = function(_k) { return variable_struct_exists(self.keys_down, string(_k)); }
		self.key_pressed = function(_k) { return variable_struct_exists(self.keys_pressed, string(_k)); }
		self.__unused = function() {
			return self;
		}
		self.uninstall = function() { ui_set_input_provider(undefined); return self; }
		self.moveTo = function(_x, _y) { self.x = _x; self.y = _y; return self; }
		self.press = function(_b = mb_left) { self.down[_b] = true; self.pressed[_b] = true; return self; }
		self.release = function(_b = mb_left) { self.down[_b] = false; self.released[_b] = true; return self; }
		self.scrollUp = function() { self.wheel = 1; return self; }
		self.scrollDown = function() { self.wheel = -1; return self; }
		self.pressKey = function(_k) { self.keys_down[$ string(_k)] = true; self.keys_pressed[$ string(_k)] = true; return self; }
		self.releaseKey = function(_k) { variable_struct_remove(self.keys_down, string(_k)); return self; }
		/// clears the one-frame states (pressed/released/wheel)
		self.endFrame = function() {
			for (var _i=0; _i<array_length(self.pressed); _i++) { self.pressed[_i] = false; self.released[_i] = false; }
			self.wheel = 0;
			self.keys_pressed = {};
			return self;
		}
	}

	/// @function gt_frame([_count])
	/// @description runs the manager's per-frame event processing `_count` times, clearing one-frame input state after each frame
	function gt_frame(_count = 1) {
		repeat (_count) {
			global.__gooey_manager_active.__processEvents();
			if (global.__gt_mouse != undefined) global.__gt_mouse.endFrame();
		}
	}

	/// @function gt_mouse()
	/// @description gets the active simulated mouse (created and installed by `gt_reset_ui()`)
	function gt_mouse() { return global.__gt_mouse; }

	/// @function gt_render()
	/// @description renders the UI (some widgets compute their size while drawing)
	function gt_render() { global.__gooey_manager_active.render(); }

	/// @function gt_center(_widget)
	/// @description returns the on-screen center of a widget as {x, y}
	function gt_center(_widget) {
		var _d = _widget.getDimensions();
		return {x: _d.x + _d.width/2, y: _d.y + _d.height/2};
	}

	/// @function gt_hover(_widget)
	/// @description moves the simulated mouse over the center of a widget and processes one frame
	function gt_hover(_widget) {
		var _c = gt_center(_widget);
		gt_mouse().moveTo(_c.x, _c.y);
		gt_frame();
	}

	/// @function gt_click(_widget, [_button])
	/// @description simulates a full click on a widget: hover, press (1 frame), release (1 frame), then moves the mouse away
	function gt_click(_widget, _button = mb_left) {
		var _c = gt_center(_widget);
		gt_mouse().moveTo(_c.x, _c.y);
		gt_frame();
		gt_mouse().press(_button);
		gt_frame();
		gt_mouse().release(_button);
		gt_frame();
		gt_mouse().moveTo(-10000, -10000);
		gt_frame();
	}

	global.__gt_mouse = undefined;

	/// @function gt_reset_ui()
	/// @description puts the UI manager back in a pristine state: destroys every widget, restores defaults and installs a fresh simulated mouse
	function gt_reset_ui() {
		__auto_create_ui_object();
		var _ui = global.__gooey_manager_active;
		try { _ui.destroyAll(); } catch (_e) { }
		_ui.__widgets = [];
		_ui.__panels = [];
		_ui.__id_map = {};
		_ui.resetScale();
		_ui.setMouseDevice(0);
		_ui.setLogMessageLevel(UI_MESSAGE_LEVEL.ERROR);
		_ui.__currentlyHoveredPanel = noone;
		_ui.__currentlyHoveredWidget = noone;
		_ui.__currentlyDraggedWidget = noone;
		_ui.__textbox_editing_ref = noone;
		_ui.__UI_interaction = false;
		_ui.__camera_id = undefined;
		keyboard_string = "";
		keyboard_lastkey = vk_nokey;
		global.__gt_mouse = new GooeyMockInput();
		global.__gt_mouse.moveTo(-10000, -10000).install();
	}

#endregion

#region Runner

	function __gt_xml_escape(_s) {
		_s = string_replace_all(_s, "&", "&amp;");
		_s = string_replace_all(_s, "<", "&lt;");
		_s = string_replace_all(_s, ">", "&gt;");
		_s = string_replace_all(_s, "\"", "&quot;");
		return _s;
	}

	/// @function gt_run_all([_filter])
	/// @description runs every registered suite and returns a results struct {total, passed, failed, errors, skipped, duration_ms, cases, xml}
	/// @param {String} [_filter] optional case-insensitive substring; only tests whose "Suite :: test" name contains it are run
	function gt_run_all(_filter = "") {
		var _res = {total: 0, passed: 0, failed: 0, errors: 0, skipped: 0, duration_ms: 0, cases: [], xml: ""};
		var _t0 = get_timer();
		var _xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<testsuites>\n";
		for (var _s=0, _ns=array_length(global.__gt.suites); _s<_ns; _s++) {
			var _suite = global.__gt.suites[_s];
			var _suite_cases = [];
			var _sf = 0, _se = 0, _ss = 0;
			var _ts = get_timer();
			for (var _i=0, _n=array_length(_suite.tests); _i<_n; _i++) {
				var _t = _suite.tests[_i];
				var _full = _suite.name + " :: " + _t.name;
				if (_filter != "" && string_pos(string_lower(_filter), string_lower(_full)) == 0) continue;
				var _case = {suite: _suite.name, name: _t.name, status: "pass", message: "", ms: 0};
				_res.total++;
				if (_t.skip) {
					_case.status = "skip";
					_res.skipped++; _ss++;
					show_debug_message(GT_LOG_PREFIX + "SKIP  " + _full);
				}
				else {
					var _c0 = get_timer();
					try {
						gt_reset_ui();
						if (_suite.__before_each != undefined) _suite.__before_each();
						_t.fn();
						if (_suite.__after_each != undefined) _suite.__after_each();
						_res.passed++;
						show_debug_message(GT_LOG_PREFIX + "PASS  " + _full);
					}
					catch (_e) {
						if (is_struct(_e) && variable_struct_exists(_e, "gt_failure")) {
							_case.status = "fail";
							_case.message = _e.message;
							_res.failed++; _sf++;
							show_debug_message(GT_LOG_PREFIX + "FAIL  " + _full + " :: " + _e.message);
						}
						else {
							_case.status = "error";
							var _where = "";
							if (is_struct(_e) && variable_struct_exists(_e, "stacktrace") && is_array(_e.stacktrace) && array_length(_e.stacktrace) > 0) _where = " @ " + string(_e.stacktrace[0]);
							_case.message = (is_struct(_e) && variable_struct_exists(_e, "message")) ? (string(_e.message) + _where) : string(_e);
							_res.errors++; _se++;
							show_debug_message(GT_LOG_PREFIX + "ERROR " + _full + " :: " + _case.message);
						}
					}
					_case.ms = (get_timer() - _c0) / 1000;
				}
				array_push(_suite_cases, _case);
				array_push(_res.cases, _case);
			}
			// Always leave the UI clean for the next suite
			try { gt_reset_ui(); } catch (_e2) {}
			_xml += "  <testsuite name=\"" + __gt_xml_escape(_suite.name) + "\" tests=\"" + string(array_length(_suite_cases)) + "\" failures=\"" + string(_sf) + "\" errors=\"" + string(_se) + "\" skipped=\"" + string(_ss) + "\" time=\"" + string((get_timer() - _ts) / 1000000) + "\">\n";
			for (var _i=0, _n=array_length(_suite_cases); _i<_n; _i++) {
				var _c = _suite_cases[_i];
				_xml += "    <testcase classname=\"" + __gt_xml_escape(_c.suite) + "\" name=\"" + __gt_xml_escape(_c.name) + "\" time=\"" + string(_c.ms / 1000) + "\"";
				if (_c.status == "pass") _xml += "/>\n";
				else if (_c.status == "skip") _xml += "><skipped/></testcase>\n";
				else _xml += "><" + (_c.status == "fail" ? "failure" : "error") + " message=\"" + __gt_xml_escape(_c.message) + "\"/></testcase>\n";
			}
			_xml += "  </testsuite>\n";
		}
		_xml += "</testsuites>\n";
		_res.xml = _xml;
		_res.duration_ms = (get_timer() - _t0) / 1000;
		return _res;
	}

#endregion
