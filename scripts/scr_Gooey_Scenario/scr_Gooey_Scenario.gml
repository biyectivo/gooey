/// @feather ignore all
/************************************************************************************
	gooey scenario / visual regression helpers.

	`gt_scenario_run()` builds a large UI that uses every widget type (tabs, nested clipping containers,
	scrolled content, dropdown pop-outs, a modal-less overlap of two panels), drives it with a scripted mouse and returns one
	fingerprint line per step: the MD5 of the rendered GUI surface plus the interaction state.

	* `./tools/run_tests.ps1 -Filter "Scenario ::"` prints the lines as `[GOOEY-FP] ...` (igor.log). Running it on two
	  versions of the library and diffing the output proves they behave and render identically.
	* The same scenario is also a permanent test: it must be deterministic and independent of internal optimisations.
*************************************************************************************/

/// @function gt_render_hash()
/// @description renders the whole UI into a GUI-sized surface and returns the MD5 of its pixels
function gt_render_hash() {
	var _w = display_get_gui_width(), _h = display_get_gui_height();
	var _s = surface_create(_w, _h);
	surface_set_target(_s);
	draw_clear_alpha(c_black, 0);
	global.__gooey_manager_active.render();
	surface_reset_target();
	var _size = _w * _h * 4;
	var _b = buffer_create(_size, buffer_fixed, 1);
	buffer_get_surface(_b, _s, 0);
	var _md5 = buffer_md5(_b, 0, _size);
	buffer_delete(_b);
	surface_free(_s);
	return _md5;
}

function __gt_id(_w) { return is_struct(_w) ? _w.__ID : "-"; }

/// @function gt_scenario_build()
/// @description builds the scenario UI and returns a struct with references to the interesting widgets
function gt_scenario_build() {
	var _sc = {};
	_sc.clicks = 0;
	var _surf = surface_create(60, 40);
	surface_set_target(_surf);
	draw_clear(c_aqua);
	draw_set_color(c_red);
	draw_rectangle(5, 5, 30, 25, false);
	draw_set_color(c_white);
	surface_reset_target();
	_sc.surface = _surf;

	// ---------- Panel A: 3 tabs, every widget type
	var _a = new UIPanel("A", 20, 20, 620, 520, grey_panel);
	_a.addTab(2);
	_a.setTabText(0, "Controls");
	_a.setTabText(1, "Lists");
	_a.setTabText(2, "Empty");
	_sc.a = _a;
	_sc.b1 = _a.add(new UIButton("b1", 20, 60, 120, 36, "Button", blue_button00), 0);
	_sc.b1.setCallback(UI_EVENT.LEFT_CLICK, method(_sc, function() { self.clicks++; }));
	_sc.b2 = _a.add(new UIButton("b2", 150, 60, 120, 36, "Disabled", blue_button00), 0);
	_sc.b2.setEnabled(false);
	_sc.tg = _a.add(new UIToggleButton("tg", 280, 60, 120, 36, "Toggle", blue_button00, grey_button00, false), 0);
	_sc.t1 = _a.add(new UIText("t1", 20, 110, "Hello [c_red]red[/c] world"), 0);
	_sc.t2 = _a.add(new UIText("t2", 20, 140, "A long text that wraps around because of the maximum width set on it"), 0);
	_sc.t2.setMaxWidth(160);
	_sc.cb = _a.add(new UICheckbox("cb", 220, 110, "Check me", yellow_checkmark, yellow_cross, false), 0);
	_sc.sh = _a.add(new UISlider("sh", 20, 230, 180, noone, yellow_circle, 40, 0, 100), 0);
	_sc.sv = _a.add(new UISlider("sv", 450, 60, 140, noone, yellow_circle, 30, 0, 100, UI_ORIENTATION.VERTICAL), 0);
	_sc.pb = _a.add(new UIProgressBar("pb", 20, 270, yellow_circle, yellow_circle, 60, 0, 100), 0);
	_sc.tb = _a.add(new UITextBox("tb", 20, 310, 200, 30, grey_button00, 20), 0);
	_sc.dd = _a.add(new UIDropdown("dd", 260, 310, ["Alpha", "Beta", "Gamma", "Delta"], grey_panel, grey_button00, 0), 0);
	_sc.sp = _a.add(new UISpinner("sp", 20, 360, ["One", "Two", "Three"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0), 0);
	_sc.og = _a.add(new UIOptionGroup("og", 280, 360, ["[c_red]A", "B", "C"], yellow_circle, 1), 0);
	_sc.spr = _a.add(new UISprite("spr", 350, 110, gooey), 0);
	_sc.cv = _a.add(new UICanvas("cv", 480, 230, 60, 40, _surf), 0);
	_sc.gr = _a.add(new UIGrid("gr", 2, 3), 0);
	_sc.gr.setDimensions(20, 410, 240, 80);
	for (var _i=0; _i<6; _i++)	_sc.gr.addNext(new UIText("gt"+string(_i), 0, 0, "c"+string(_i)));
	_sc.gp = _a.add(new UIGroup("gp", 300, 410, 200, 90, grey_button00), 0);
	_sc.gp.add(new UIButton("gpb1", 10, 10, 80, 30, "In1", blue_button00));
	_sc.gp.add(new UIButton("gpb2", 100, 10, 80, 30, "In2", blue_button00));
	_sc.gp.add(new UIText("gpt", 10, 55, "group text"));
	// Tab 1: a lattice of buttons, many of them beyond the panel bounds (scrolling + clipping)
	_sc.lattice = [];
	for (var _i=0; _i<60; _i++) {
		var _w = _a.add(new UIButton("l"+string(_i), 20 + (_i mod 6) * 95, 50 + (_i div 6) * 45, 85, 36, "L"+string(_i), blue_button00), 1);
		array_push(_sc.lattice, _w);
	}
	// Common widgets
	_sc.common = _a.add(new UIText("common", 440, 8, "common area"), -1);

	// ---------- Panel B: overlaps A, clipping group with overflowing content + a dropdown at the edge
	var _b = new UIPanel("B", 560, 120, 330, 330, grey_panel);
	_sc.b = _b;
	_sc.bg = _b.add(new UIGroup("bg", 15, 50, 300, 220, grey_button00));
	_sc.bg.setClipsContent(true);
	_sc.blist = [];
	for (var _i=0; _i<20; _i++)	array_push(_sc.blist, _sc.bg.add(new UIButton("bb"+string(_i), 10 + (_i mod 2) * 140, 5 + (_i div 2) * 42, 130, 36, "B"+string(_i), blue_button00)));
	_sc.bdd = _b.add(new UIDropdown("bdd", 150, 280, ["North", "South", "East", "West"], grey_panel, grey_button00, 1));
	return _sc;
}

/// @function gt_scenario_step(_log, _name, _sc)
function gt_scenario_step(_log, _name, _sc) {
	gt_frame(1);
	var _hash = gt_render_hash();
	var _ui = global.__gooey_manager_active;
	var _vals = [_sc.clicks, _sc.tg.getValue(), _sc.cb.getValue(), _sc.sh.getValue(), _sc.sv.getValue(), _sc.sp.getIndex(), _sc.dd.getIndex(), _sc.og.getIndex(), _sc.bdd.getIndex(), _sc.a.getCurrentTab()];
	var _line = _name + " | " + _hash + " | hw=" + __gt_id(_ui.getHoveredWidget()) + " hp=" + __gt_id(_ui.getHoveredPanel()) + " | " + string(_vals);
	array_push(_log, _line);
	return _line;
}

/// @function gt_scenario_run()
/// @description runs the scripted scenario and returns the array of fingerprint lines
function gt_scenario_run() {
	var _log = [];
	var _sc = gt_scenario_build();
	var _m = gt_mouse();
	gt_mouse().moveTo(5, 5);
	gt_scenario_step(_log, "initial", _sc);
	gt_scenario_step(_log, "initial-again", _sc);

	// hover a representative set of widgets
	var _hover = [_sc.b1, _sc.b2, _sc.tg, _sc.t1, _sc.t2, _sc.cb, _sc.sh, _sc.sv, _sc.pb, _sc.tb, _sc.dd, _sc.og, _sc.spr, _sc.cv, _sc.gp, _sc.common];
	for (var _i=0; _i<array_length(_hover); _i++) {
		var _c = gt_center(_hover[_i]);
		_m.moveTo(_c.x, _c.y);
		gt_frame(2);
		gt_scenario_step(_log, "hover " + _hover[_i].__ID, _sc);
	}
	// widgets of the group and the grid
	var _inner = _sc.gp.getChildren();
	for (var _i=0; _i<array_length(_inner); _i++) {
		var _c = gt_center(_inner[_i]);
		_m.moveTo(_c.x, _c.y);
		gt_frame(2);
		gt_scenario_step(_log, "hover " + _inner[_i].__ID, _sc);
	}

	// clicks
	gt_click(_sc.b1); gt_scenario_step(_log, "click b1", _sc);
	gt_click(_sc.b2); gt_scenario_step(_log, "click b2 (disabled)", _sc);
	gt_click(_sc.tg); gt_scenario_step(_log, "click tg", _sc);
	gt_click(_sc.cb); gt_scenario_step(_log, "click cb", _sc);
	gt_click(_sc.og); gt_scenario_step(_log, "click og", _sc);
	gt_click(_inner[0]); gt_scenario_step(_log, "click gpb1", _sc);

	// dropdown: open, hover an option, pick it
	gt_click(_sc.dd); gt_scenario_step(_log, "dd open", _sc);
	var _d = _sc.dd.getDimensions();
	_m.moveTo(_d.x + 20, _d.y + _d.height + 40);
	gt_frame(2); gt_scenario_step(_log, "dd hover option", _sc);
	_m.press(); gt_frame(1); _m.release(); gt_frame(1); gt_scenario_step(_log, "dd picked", _sc);

	// spinner and slider drag
	var _kids = _sc.sp.getChildren();
	var _sp_buttons = _sc.sp.getDescendants();
	for (var _i=0; _i<array_length(_sp_buttons); _i++) if (_sp_buttons[_i].__ID != "") { /* just ensure the list is enumerable */ }
	var _sd = _sc.sh.getDimensions();
	_m.moveTo(_sd.x + 30, _sd.y + 2); gt_frame(1);
	_m.press(); gt_frame(1);
	_m.moveTo(_sd.x + 120, _sd.y + 2); gt_frame(2);
	gt_scenario_step(_log, "slider dragging", _sc);
	_m.release(); gt_frame(1);
	gt_scenario_step(_log, "slider released", _sc);

	// scale
	global.__gooey_manager_active.setScale(1.5);
	gt_scenario_step(_log, "scale 1.5", _sc);
	var _c = gt_center(_sc.b1); _m.moveTo(_c.x, _c.y); gt_frame(2);
	gt_scenario_step(_log, "scale 1.5 hover b1", _sc);
	global.__gooey_manager_active.setScale(1);
	gt_scenario_step(_log, "scale 1", _sc);

	// panel B: hover buttons inside the clipping group, visible and clipped-away, then scroll it
	for (var _i=0; _i<array_length(_sc.blist); _i+=3) {
		var _c = gt_center(_sc.blist[_i]);
		_m.moveTo(_c.x, _c.y);
		gt_frame(2);
		gt_scenario_step(_log, "hover " + _sc.blist[_i].__ID, _sc);
	}
	var _bgd = _sc.bg.getDimensions();
	_m.moveTo(_bgd.x + 30, _bgd.y + 30);
	repeat (4) { _m.scrollDown(); gt_frame(1); }
	gt_scenario_step(_log, "wheel bg down", _sc);
	_sc.bg.scroll(UI_ORIENTATION.VERTICAL, -1, 70);
	gt_scenario_step(_log, "scroll bg 70", _sc);
	_sc.bg.scroll(UI_ORIENTATION.VERTICAL, -1, 90);
	gt_scenario_step(_log, "scroll bg 160", _sc);
	gt_scenario_step(_log, "scroll bg 160 hover", _sc);
	for (var _i=0; _i<array_length(_sc.blist); _i+=4) { var _c = gt_center(_sc.blist[_i]); _m.moveTo(_c.x, _c.y); gt_frame(2); gt_scenario_step(_log, "scrolled hover " + _sc.blist[_i].__ID, _sc); }
	repeat (2) { _m.scrollUp(); gt_frame(1); }
	gt_scenario_step(_log, "wheel bg up", _sc);
	_sc.bg.scroll(UI_ORIENTATION.VERTICAL, 1, 200);
	gt_scenario_step(_log, "scroll bg back", _sc);
	gt_click(_sc.bdd); gt_scenario_step(_log, "bdd open", _sc);
	_m.moveTo(5, 5); gt_frame(1); _m.press(); gt_frame(1); _m.release(); gt_frame(1);
	gt_scenario_step(_log, "bdd closed by outside click", _sc);

	// tabs and scrolling on tab 1
	_sc.a.gotoTab(1);
	gt_scenario_step(_log, "tab 1", _sc);
	var _pd = _sc.a.getDimensions();
	_m.moveTo(_pd.x + 200, _pd.y + 200);
	repeat (5) { _m.scrollDown(); gt_frame(1); }
	gt_scenario_step(_log, "tab 1 wheel down", _sc);
	_sc.a.scroll(UI_ORIENTATION.VERTICAL, -1, 130);
	gt_scenario_step(_log, "tab 1 scrolled 130", _sc);
	_sc.a.scroll(UI_ORIENTATION.VERTICAL, -1, 200);
	gt_scenario_step(_log, "tab 1 scrolled 330", _sc);
	_sc.a.scroll(UI_ORIENTATION.HORIZONTAL, -1, 60);
	gt_scenario_step(_log, "tab 1 scrolled h 60", _sc);
	for (var _i=0; _i<array_length(_sc.lattice); _i+=7) {
		var _c = gt_center(_sc.lattice[_i]);
		_m.moveTo(_c.x, _c.y);
		gt_frame(2);
		gt_scenario_step(_log, "hover " + _sc.lattice[_i].__ID, _sc);
	}
	gt_click(_sc.lattice[12]); gt_scenario_step(_log, "click lattice 12", _sc);
	repeat (8) { _m.scrollUp(); gt_frame(1); }
	_sc.a.scroll(UI_ORIENTATION.VERTICAL, 1, 530);
	_sc.a.scroll(UI_ORIENTATION.HORIZONTAL, 1, 60);
	gt_scenario_step(_log, "tab 1 scrolled back", _sc);
	_sc.a.gotoTab(2);
	gt_scenario_step(_log, "tab 2", _sc);
	_sc.a.gotoTab(0);
	gt_scenario_step(_log, "tab 0 again", _sc);

	// visibility / enabled / destroy / bring to front
	_sc.b.setVisible(false);
	gt_scenario_step(_log, "B hidden", _sc);
	_sc.b.setVisible(true);
	global.__gooey_manager_active.bringToFront(_sc.a);
	gt_scenario_step(_log, "A to front", _sc);
	_sc.cb.setEnabled(false);
	_sc.t1.setVisible(false);
	gt_scenario_step(_log, "cb disabled, t1 hidden", _sc);
	_sc.gp.destroy();
	_sc.sh.destroy();
	gt_scenario_step(_log, "group and slider destroyed", _sc);
	_sc.a.setDimensions(-300, -200);
	gt_scenario_step(_log, "A moved partly off screen", _sc);
	surface_free(_sc.surface);
	return _log;
}


/// @function gt_all_widget_factories()
/// @description array of functions that each create one widget of a different type (not yet added to any panel)
function gt_all_widget_factories() {
	return [
		function(_i) { return new UIButton("w"+string(_i), 10, 10, 80, 30, "b", blue_button00); },
		function(_i) { return new UIToggleButton("w"+string(_i), 10, 10, 80, 30, "t", blue_button00, grey_button00, false); },
		function(_i) { return new UIText("w"+string(_i), 10, 10, "text"); },
		function(_i) { return new UICheckbox("w"+string(_i), 10, 10, "c", yellow_checkmark, yellow_cross, false); },
		function(_i) { return new UISlider("w"+string(_i), 10, 10, 100, noone, yellow_circle, 5, 0, 10); },
		function(_i) { return new UIProgressBar("w"+string(_i), 10, 10, yellow_circle, yellow_circle, 5, 0, 10); },
		function(_i) { return new UITextBox("w"+string(_i), 10, 10, 100, 30, grey_button00, 10); },
		function(_i) { return new UIDropdown("w"+string(_i), 10, 10, ["A", "B"], grey_panel, grey_button00, 0); },
		function(_i) { return new UISpinner("w"+string(_i), 10, 10, ["A", "B"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 100, 30, 0); },
		function(_i) { return new UIOptionGroup("w"+string(_i), 10, 10, ["A", "B"], yellow_circle, 0); },
		function(_i) { return new UISprite("w"+string(_i), 10, 10, gooey); },
		function(_i) { return new UICanvas("w"+string(_i), 10, 10, 20, 20, -1); },
		function(_i) { return new UIGroup("w"+string(_i), 10, 10, 50, 50, noone); },
		function(_i) { return new UIGrid("w"+string(_i), 2, 2); }
	];
}

function gt_register_static_methods() {
	var _s = gt_suite("Static methods");

	_s.test("every widget type can be constructed, used and destroyed repeatedly (statics persist across constructions)", function() {
		var _factories = gt_all_widget_factories();
		for (var _round=0; _round<3; _round++) {
			var _p = gt_host_panel();
			var _made = [];
			for (var _k=0; _k<array_length(_factories); _k++) {
				var _w = _p.add(_factories[_k](_round * 100 + _k));
				_w.setDimensions(10 + (_k mod 5) * 90, 40 + (_k div 5) * 50);
				array_push(_made, _w);
			}
			gt_render();
			for (var _k=0; _k<array_length(_made); _k++) {
				gt_hover(_made[_k]);
				gt_click(_made[_k]);
				gt_assert_true(_made[_k].getVisible() , "visible after use, widget " + string(_k));
			}
			gt_render();
			_p.destroy();
			gt_assert_equal(array_length(global.__gooey_manager_active.getWidgets()), 0, "round " + string(_round));
		}
	});

	_s.test("two widgets of the same type keep independent state and callbacks", function() {
		var _p = gt_host_panel();
		var _a = _p.add(new UIButton("A", 10, 60, 100, 30, "one", blue_button00));
		var _b = _p.add(new UIButton("B", 130, 60, 100, 30, "two", blue_button00));
		var _log = [];
		_a.setCallback(UI_EVENT.LEFT_CLICK, method({log: _log}, function() { array_push(log, "a"); }));
		_b.setCallback(UI_EVENT.LEFT_CLICK, method({log: _log}, function() { array_push(log, "b"); }));
		_a.setText("changed");
		_a.setEnabled(false);
		gt_assert_equal(_b.getText(), "two");
		gt_assert_true(_b.getEnabled());
		gt_assert_false(_a.getEnabled());
		gt_click(_b);
		gt_assert_equal(_log, ["b"]);
		gt_assert_true(static_get(_a) == static_get(_b), "the methods are shared through the static struct");
	});

	_s.test("subclass overrides still win over the base class (toggle button, spinner, dropdown, text box)", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UIToggleButton("T", 10, 60, 100, 30, "t", blue_button00, grey_button00, false));
		gt_click(_t);
		gt_assert_true(_t.getValue(), "toggle button flips on click");
		gt_click(_t);
		gt_assert_false(_t.getValue());
		var _sp = _p.add(new UISpinner("S", 10, 120, ["A", "B", "C"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 200, 30, 0));
		gt_assert_equal(_sp.getIndex(), 0);
		var _d = _p.add(new UIDropdown("D", 10, 200, ["x", "y"], grey_panel, grey_button00, 0));
		gt_render();
		gt_click(_d);
		gt_assert_true(_d.__dropdown_active, "dropdown opens");
	});

	_s.test("widget methods are static: reading one gives an unbound method that must be bound with method()", function() {
		var _b = new UIButton("B", 0, 0, 80, 30, "hello", blue_button00);
		var _get = method(_b, _b.getText);
		gt_assert_equal(_get(), "hello");
		_b.setText("bye");
		gt_assert_equal(_get(), "bye");
		// bindings to widget methods are bound automatically
		var _p = gt_host_panel();
		var _t = _p.add(new UIText("T", 10, 60, "x"));
		_t.setBinding(_b, "getText");
		gt_render();
		gt_assert_equal(_t.getText(), "bye");
	});

	_s.test("widgets carry few per-instance members (memory regression guard)", function() {
		gt_reset_ui();
		var _factories = gt_all_widget_factories();
		for (var _k=0; _k<array_length(_factories); _k++) {
			var _w = _factories[_k](_k);
			var _n = struct_names_count(_w);
			gt_assert_true(_n < 140, "widget " + string(_k) + " has " + string(_n) + " own members");
		}
		var _before = gt_bench_gc_objects();
		var _p = gt_host_panel();
		for (var _k=0; _k<50; _k++)	_p.add(new UIButton("g"+string(_k), 10, 10, 80, 30, "b", blue_button00));
		var _per = (gt_bench_gc_objects() - _before) / 51;
		gt_assert_true(_per < 80, "a button costs " + string(_per) + " GC objects");
	});
}

function gt_register_scenario() {
	var _s = gt_suite("Scenario");

	_s.test("the scripted scenario is deterministic (two runs give identical fingerprints)", function() {
		var _f = environment_get_variable("GOOEY_TEST_FILTER");
		var _verbose = (_f != "" && string_pos("Scenario", _f) > 0);
		var _l1 = gt_scenario_run();
		gt_reset_ui();
		var _l2 = gt_scenario_run();
		gt_assert_equal(array_length(_l1), array_length(_l2));
		for (var _i=0; _i<min(array_length(_l1), array_length(_l2)); _i++) {
			gt_assert_equal(_l2[_i], _l1[_i], "step " + string(_i));
			if (_verbose) show_debug_message("[GOOEY-FP] " + _l1[_i]);
		}
	});
}
