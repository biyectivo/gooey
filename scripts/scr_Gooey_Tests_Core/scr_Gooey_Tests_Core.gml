/// @feather ignore all
/************************************************************************************
	gooey tests - core: UI manager, registry, convenience functions, positioning,
	base widget behavior (hierarchy, callbacks, binding, destroy...)
*************************************************************************************/

function gt_register_manager() {
	var _s = gt_suite("Manager");

	_s.test("manager object is auto-created and registered globally", function() {
		gt_assert_true(variable_global_exists("__gooey_manager_active"));
		gt_assert_true(instance_exists(global.__gooey_manager_active));
		gt_assert_equal(global.__gooey_manager_active.object_index, UI);
	});

	_s.test("input provider can be installed and removed", function() {
		gt_assert_defined(ui_get_input_provider());
		ui_set_input_provider(undefined);
		gt_assert_undefined(ui_get_input_provider());
	});

	_s.test("widgets register in the manager and can be found by ID", function() {
		var _p = new UIPanel("P1", 0, 0, 100, 100, grey_panel);
		gt_assert_true(ui_exists("P1"));
		gt_assert_true(ui_get("P1") == _p);
		gt_assert_false(ui_exists("nope"));
		gt_assert_equal(ui_get("nope"), noone);
	});

	_s.test("duplicate IDs are renamed with a numeric suffix", function() {
		var _a = new UIPanel("Dup", 0, 0, 100, 100, grey_panel);
		var _b = new UIPanel("Dup", 0, 0, 100, 100, grey_panel);
		gt_assert_equal(_a.getID(), "Dup");
		gt_assert_equal(_b.getID(), "Dup1");
		gt_assert_true(ui_get("Dup1") == _b);
	});

	_s.test("destroying a panel unregisters it and all its descendants", function() {
		var _p = new UIPanel("P1", 0, 0, 300, 300, grey_panel);
		var _g = _p.add(new UIGroup("G1", 0, 0, 100, 100, noone));
		_g.add(new UIButton("B1", 0, 0, 50, 20, "x", blue_button00));
		_p.destroy();
		gt_assert_false(ui_exists("P1"));
		gt_assert_false(ui_exists("G1"));
		gt_assert_false(ui_exists("B1"));
		gt_assert_equal(array_length(ui_get_panels()), 0);
		gt_assert_equal(array_length(ui_get_widgets()), 0);
	});

	_s.test("cleanup() destroys every panel and widget", function() {
		new UIPanel("A", 0, 0, 100, 100, grey_panel);
		new UIPanel("B", 0, 0, 100, 100, grey_panel).add(new UIText("T", 0, 0, "hi"));
		global.__gooey_manager_active.cleanup();
		gt_assert_equal(array_length(ui_get_widgets()), 0);
		gt_assert_equal(array_length(ui_get_panels()), 0);
	});

	_s.test("the last created panel is the focused one; setFocusedPanel reorders", function() {
		var _a = new UIPanel("A", 0, 0, 100, 100, grey_panel);
		var _b = new UIPanel("B", 0, 0, 100, 100, grey_panel);
		gt_assert_true(ui_get_focused_panel() == _b);
		ui_set_focused_panel("A");
		gt_assert_true(ui_get_focused_panel() == _a);
		gt_assert_equal(array_length(ui_get_panels()), 2);
	});

	_s.test("setFocusedPanel with an unknown ID does not corrupt the panel list", function() {
		var _a = new UIPanel("A", 0, 0, 100, 100, grey_panel);
		new UIPanel("B", 0, 0, 100, 100, grey_panel);
		gt_assert_no_throw(function() { ui_set_focused_panel("does-not-exist"); });
		var _panels = ui_get_panels();
		gt_assert_equal(array_length(_panels), 2);
		for (var _i=0; _i<array_length(_panels); _i++) gt_assert_true(is_struct(_panels[_i]), "panel list entry " + string(_i));
	});

	_s.test("getFocusedPanel returns -1 when there are no panels", function() {
		gt_assert_equal(ui_get_focused_panel(), -1);
	});

	_s.test("global scale: set, get, reset", function() {
		var _ui = global.__gooey_manager_active;
		gt_assert_equal(_ui.getScale(), 1);
		_ui.setScale(2);
		gt_assert_equal(_ui.getScale(), 2);
		_ui.resetScale();
		gt_assert_equal(_ui.getScale(), 1);
	});

	_s.test("ui_set_scale / ui_get_scale / ui_reset_scale convenience functions", function() {
		ui_set_scale(1.5);
		gt_assert_equal(ui_get_scale(), 1.5);
		ui_reset_scale();
		gt_assert_equal(ui_get_scale(), 1);
	});

	_s.test("log level and mouse device accessors", function() {
		ui_set_log_message_level(UI_MESSAGE_LEVEL.INFO);
		gt_assert_equal(ui_get_log_message_level(), UI_MESSAGE_LEVEL.INFO);
		ui_set_mouse_device(3);
		gt_assert_equal(ui_get_mouse_device(), 3);
	});

	_s.test("isInteracting is true only while the pointer is over a panel", function() {
		var _p = new UIPanel("P", 100, 100, 200, 200, grey_panel);
		gt_mouse().moveTo(5, 5);
		gt_frame();
		gt_assert_false(ui_is_interacting());
		gt_mouse().moveTo(150, 150);
		gt_frame();
		gt_assert_true(ui_is_interacting());
		gt_assert_true(ui_get_currently_hovered_panel() == _p);
		gt_mouse().moveTo(5, 5);
		gt_frame();
		gt_assert_false(ui_is_interacting());
	});

	_s.test("topmost overlapping panel receives the hover", function() {
		var _a = new UIPanel("A", 100, 100, 200, 200, grey_panel);
		var _b = new UIPanel("B", 150, 150, 200, 200, grey_panel);
		gt_mouse().moveTo(200, 200);
		gt_frame();
		gt_assert_true(ui_get_currently_hovered_panel() == _b);
	});

	_s.test("clicking a background panel brings it to the front", function() {
		var _a = new UIPanel("A", 100, 100, 200, 200, grey_panel);
		var _b = new UIPanel("B", 400, 100, 200, 200, grey_panel);
		gt_assert_true(ui_get_focused_panel() == _b);
		gt_mouse().moveTo(150, 250);
		gt_frame();
		gt_mouse().press();
		gt_frame();
		gt_mouse().release();
		gt_frame();
		gt_assert_true(ui_get_focused_panel() == _a);
	});

	_s.test("a modal panel blocks interaction everywhere (clicks never reach the game)", function() {
		var _a = new UIPanel("A", 100, 100, 200, 200, grey_panel);
		var _m = new UIPanel("M", 600, 100, 200, 200, grey_panel);
		_m.setModal(true);
		gt_mouse().moveTo(5, 5);
		gt_frame();
		gt_assert_true(ui_is_interacting(), "pointer outside every panel while a modal is open");
		gt_mouse().moveTo(150, 150);
		gt_frame();
		gt_assert_true(ui_is_interacting(), "pointer over a disabled background panel");
	});

	_s.test("ui_get_widgets_by_type / ui_destroy_all / widget count", function() {
		var _p = new UIPanel("P", 0, 0, 300, 300, grey_panel);
		_p.add(new UISprite("S1", 0, 0, noone));
		_p.add(new UISprite("S2", 0, 60, noone));
		gt_assert_equal(array_length(ui_get_widgets_by_type(UI_TYPE.SPRITE)), 2);
		gt_assert_equal(array_length(ui_get_widgets_by_type(UI_TYPE.PANEL)), 1);
		ui_destroy_all();
		gt_assert_equal(array_length(ui_get_widgets()), 0);
	});

	_s.test("keep_allowed_chars filters characters by class", function() {
		var _f = global.__gooey_manager_active.__keep_allowed_chars;
		gt_assert_equal(_f("aB 1,.", true, true, true, true, true, ",."), "aB 1,.");
		gt_assert_equal(_f("aB 1,.", false, true, true, true, true, ",."), "B 1,.");
		gt_assert_equal(_f("aB 1,.", true, false, true, true, true, ",."), "a 1,.");
		gt_assert_equal(_f("aB 1,.", true, true, false, true, true, ",."), "aB1,.");
		gt_assert_equal(_f("aB 1,.", true, true, true, false, true, ",."), "aB ,.");
		gt_assert_equal(_f("aB 1,.", true, true, true, true, false, ",."), "aB 1");
		gt_assert_equal(_f("a-b_c", true, true, true, true, true, "-"), "a-bc");
	});

	_s.test("keep_allowed_chars: with no symbol whitelist, disallowed letters stay filtered", function() {
		var _f = global.__gooey_manager_active.__keep_allowed_chars;
		gt_assert_equal(_f("abc123", false, true, true, true, true, ""), "123");
	});
}

function gt_register_positioning() {
	var _s = gt_suite("Positioning");

	_s.test("TOP_LEFT anchor places the widget at the offset", function() {
		var _p = new UIPanel("P", 30, 40, 200, 100, grey_panel);
		var _d = _p.getDimensions();
		gt_assert_equal(_d.x, 30);
		gt_assert_equal(_d.y, 40);
		gt_assert_equal(_d.width, 200);
		gt_assert_equal(_d.height, 100);
	});

	_s.test("all nine anchor points against the GUI", function() {
		var _gw = display_get_gui_width(), _gh = display_get_gui_height();
		var _w = 100, _h = 60;
		var _cases = [
			[UI_RELATIVE_TO.TOP_LEFT,      0,        0],
			[UI_RELATIVE_TO.TOP_CENTER,    _gw/2 - _w/2, 0],
			[UI_RELATIVE_TO.TOP_RIGHT,     _gw - _w, 0],
			[UI_RELATIVE_TO.MIDDLE_LEFT,   0,        _gh/2 - _h/2],
			[UI_RELATIVE_TO.MIDDLE_CENTER, _gw/2 - _w/2, _gh/2 - _h/2],
			[UI_RELATIVE_TO.MIDDLE_RIGHT,  _gw - _w, _gh/2 - _h/2],
			[UI_RELATIVE_TO.BOTTOM_LEFT,   0,        _gh - _h],
			[UI_RELATIVE_TO.BOTTOM_CENTER, _gw/2 - _w/2, _gh - _h],
			[UI_RELATIVE_TO.BOTTOM_RIGHT,  _gw - _w, _gh - _h]
		];
		for (var _i=0; _i<array_length(_cases); _i++) {
			var _c = _cases[_i];
			var _p = new UIPanel("Anchor" + string(_i), 0, 0, _w, _h, grey_panel, _c[0]);
			var _d = _p.getDimensions();
			gt_assert_near(_d.x, _c[1], 0.01, "x for anchor " + string(_c[0]));
			gt_assert_near(_d.y, _c[2], 0.01, "y for anchor " + string(_c[0]));
		}
	});

	_s.test("offsets are applied from the anchor corner", function() {
		var _gw = display_get_gui_width(), _gh = display_get_gui_height();
		var _p = new UIPanel("P", -10, -20, 100, 60, grey_panel, UI_RELATIVE_TO.BOTTOM_RIGHT);
		var _d = _p.getDimensions();
		gt_assert_near(_d.x, _gw - 10 - 100);
		gt_assert_near(_d.y, _gh - 20 - 60);
	});

	_s.test("children are positioned relative to their parent", function() {
		var _p = new UIPanel("P", 100, 50, 300, 200, grey_panel);
		var _b = _p.add(new UIButton("B", 10, 20, 80, 30, "b", blue_button00));
		var _d = _b.getDimensions();
		gt_assert_equal(_d.x, 110);
		gt_assert_equal(_d.y, 70);
		gt_assert_equal(_d.relative_x, 10);
		gt_assert_equal(_d.relative_y, 20);
	});

	_s.test("children anchored to the parent's center/bottom-right", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		var _c = _p.add(new UIGroup("C", 0, 0, 40, 20, noone, UI_RELATIVE_TO.MIDDLE_CENTER));
		var _br = _p.add(new UIGroup("BR", -5, -5, 40, 20, noone, UI_RELATIVE_TO.BOTTOM_RIGHT));
		gt_assert_equal(_c.getDimensions().x, 100 + 150 - 20);
		gt_assert_equal(_c.getDimensions().y, 100 + 100 - 10);
		gt_assert_equal(_br.getDimensions().x, 100 + 300 - 5 - 40);
		gt_assert_equal(_br.getDimensions().y, 100 + 200 - 5 - 20);
	});

	_s.test("moving or resizing the parent updates children", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		var _b = _p.add(new UIGroup("G", 10, 10, 50, 50, noone));
		_p.setDimensions(200, 300);
		gt_assert_equal(_b.getDimensions().x, 210);
		gt_assert_equal(_b.getDimensions().y, 310);
	});

	_s.test("setDimensions with only some arguments keeps the others and is chainable", function() {
		var _p = new UIPanel("P", 10, 20, 300, 200, grey_panel);
		gt_assert_true(_p.setDimensions(,, 111) == _p);
		var _d = _p.getDimensions();
		gt_assert_equal(_d.width, 111);
		gt_assert_equal(_d.height, 200);
		gt_assert_equal(_d.x, 10);
	});

	_s.test("inherit width/height copy the parent's size", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 1, 1, noone));
		_g.setInheritWidth(true).setInheritHeight(true);
		gt_assert_equal(_g.getDimensions().width, 300);
		gt_assert_equal(_g.getDimensions().height, 200);
		gt_assert_true(_g.getInheritWidth());
		gt_assert_true(_g.getInheritHeight());
		_p.setDimensions(,, 400, 250);
		gt_assert_equal(_g.getDimensions().width, 400);
		gt_assert_equal(_g.getDimensions().height, 250);
	});

	_s.test("scrolling moves children and is tracked cumulatively", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 10, 10, 50, 50, noone));
		_p.scroll(UI_ORIENTATION.VERTICAL, 1, 25);
		gt_assert_equal(_g.getDimensions().y, 35);
		gt_assert_equal(_p.getScrollOffset(UI_ORIENTATION.VERTICAL), 25);
		_p.scroll(UI_ORIENTATION.HORIZONTAL, -1, 5);
		gt_assert_equal(_g.getDimensions().x, 5);
		_p.resetScroll(UI_ORIENTATION.VERTICAL);
		_p.resetScroll(UI_ORIENTATION.HORIZONTAL);
		gt_assert_equal(_g.getDimensions().x, 10);
		gt_assert_equal(_g.getDimensions().y, 10);
	});

	_s.test("setScrollOffset goes to an absolute value", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 50, 50, noone));
		_p.setScrollOffset(UI_ORIENTATION.VERTICAL, 40);
		gt_assert_equal(_g.getDimensions().y, 40);
		_p.setScrollOffset(UI_ORIENTATION.VERTICAL, 10);
		gt_assert_equal(_g.getDimensions().y, 10);
	});

	_s.test("dimensions toString does not crash", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _b = _p.add(new UIGroup("G", 0, 0, 50, 50, noone));
		gt_assert_no_throw(method({d: _b.getDimensions()}, function() { var _s = string(d); }));
	});

	_s.test("room_x_to_gui / room_y_to_gui map the active camera to the GUI", function() {
		var _cam = camera_create_view(100, 200, 640, 360);
		var _gw = display_get_gui_width(), _gh = display_get_gui_height();
		gt_assert_near(room_x_to_gui(100, _cam), 0);
		gt_assert_near(room_y_to_gui(200, _cam), 0);
		gt_assert_near(room_x_to_gui(100 + 640, _cam), _gw);
		gt_assert_near(room_y_to_gui(200 + 360, _cam), _gh);
		camera_destroy(_cam);
	});
}

function gt_register_widget_base() {
	var _s = gt_suite("Widget base");

	_s.test("basic getters and chaining setters", function() {
		var _b = new UIButton("B", 0, 0, 80, 30, "hi", blue_button00);
		gt_assert_equal(_b.getID(), "B");
		gt_assert_equal(_b.getType(), UI_TYPE.BUTTON);
		gt_assert_true(_b.setSprite(grey_button00) == _b);
		gt_assert_equal(_b.getSprite(), grey_button00);
		_b.setImage(1).setImageAlpha(0.5).setImageBlend(c_red);
		gt_assert_equal(_b.getImage(), 1);
		gt_assert_equal(_b.getImageAlpha(), 0.5);
		gt_assert_equal(_b.getImageBlend(), c_red);
	});

	_s.test("visible/enabled cascade to children", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		_g.setVisible(false);
		gt_assert_false(_g.getVisible());
		gt_assert_false(_b.getVisible());
		_g.setEnabled(false);
		gt_assert_false(_b.getEnabled());
		_g.setVisible(true).setEnabled(true);
		gt_assert_true(_b.getVisible());
		gt_assert_true(_b.getEnabled());
	});

	_s.test("hiding a panel hides and disables widgets in every tab and in the common area", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		_p.addTab();
		var _b0 = _p.add(new UIButton("B0", 0, 0, 50, 20, "b", blue_button00), 0);
		var _b1 = _p.add(new UIButton("B1", 0, 0, 50, 20, "b", blue_button00), 1);
		var _bc = _p.add(new UIButton("BC", 0, 0, 50, 20, "b", blue_button00), -1);
		_p.setVisible(false);
		gt_assert_false(_b0.getVisible());
		gt_assert_false(_b1.getVisible(), "widget on the non-current tab");
		gt_assert_false(_bc.getVisible(), "common widget");
		_p.setVisible(true);
		gt_assert_true(_b1.getVisible());
		gt_assert_true(_bc.getVisible());
	});

	_s.test("user data", function() {
		var _b = new UIButton("B", 0, 0, 80, 30, "hi", blue_button00);
		gt_assert_undefined(_b.getUserData("missing"));
		gt_assert_true(_b.setUserData("k", 42) == _b);
		gt_assert_equal(_b.getUserData("k"), 42);
	});

	_s.test("callbacks: set/get, methods are bound, non-callables are ignored", function() {
		var _b = new UIButton("B", 0, 0, 80, 30, "hi", blue_button00);
		var _f = function() { return 7; };
		_b.setCallback(UI_EVENT.LEFT_CLICK, _f);
		var _g = _b.getCallback(UI_EVENT.LEFT_CLICK);
		gt_assert_equal(_g(), 7);
		_b.setCallback(UI_EVENT.LEFT_CLICK, "not a function");
		var _h = _b.getCallback(UI_EVENT.LEFT_CLICK);
		gt_assert_equal(_h(), 7, "a non-callable must not replace the callback");
	});

	_s.test("all 14 drill-through getters/setters round-trip", function() {
		var _b = new UIButton("B", 0, 0, 80, 30, "hi", blue_button00);
		var _names = ["LeftClick","LeftHold","LeftRelease","MiddleClick","MiddleHold","MiddleRelease","RightClick","RightHold","RightRelease","MouseEnter","MouseExit","MouseOver","MouseWheelUp","MouseWheelDown"];
		for (var _i=0; _i<array_length(_names); _i++) {
			// widget methods are static (shared): they must be bound to the widget before being used as values
			var _get = method(_b, variable_struct_get(_b, "getDrillThrough" + _names[_i]));
			var _set = method(_b, variable_struct_get(_b, "setDrillThrough" + _names[_i]));
			gt_assert_true(is_callable(_get) && is_callable(_set), _names[_i]);
			var _orig = _get();
			_set(!_orig);
			gt_assert_equal(_get(), !_orig, _names[_i]);
		}
	});

	_s.test("add / remove / getChildren / getParent", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		gt_assert_true(_b.getParent() == _g);
		gt_assert_equal(array_length(_g.getChildren()), 1);
		gt_assert_true(_g.remove("B"));
		gt_assert_equal(array_length(_g.getChildren()), 0);
		gt_assert_false(_g.remove("B"));
	});

	_s.test("add returns the added child (for `with` chaining)", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _b = new UIButton("B", 0, 0, 50, 20, "b", blue_button00);
		gt_assert_true(_p.add(_b) == _b);
	});

	_s.test("a panel cannot be added to another widget", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _q = new UIPanel("Q", 0, 0, 300, 200, grey_panel);
		gt_assert_throws(method({p: _p, q: _q}, function() { p.add(q); }));
	});

	_s.test("adding a widget to a new parent detaches it from the old one", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g1 = _p.add(new UIGroup("G1", 0, 0, 100, 100, noone));
		var _g2 = _p.add(new UIGroup("G2", 0, 0, 100, 100, noone));
		var _b = _g1.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		_g2.add(_b);
		gt_assert_equal(array_length(_g1.getChildren()), 0, "old parent no longer lists the widget");
		gt_assert_equal(array_length(_g2.getChildren()), 1);
		gt_assert_true(_b.getParent() == _g2);
	});

	_s.test("a widget cannot be added to itself or to its own descendant", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _h = _g.add(new UIGroup("H", 0, 0, 50, 50, noone));
		gt_assert_throws(method({g: _g}, function() { g.add(g); }));
		gt_assert_throws(method({g: _g, h: _h}, function() { h.add(g); }));
	});

	_s.test("getDescendants returns children, grandchildren and common widgets", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		var _d = _p.getDescendants();
		gt_assert_true(array_contains(_d, _g));
		gt_assert_true(array_contains(_d, _b));
		var _gd = _g.getDescendants();
		gt_assert_equal(array_length(_gd), 1);
		gt_assert_true(_gd[0] == _b);
	});

	_s.test("getContainingPanel and getContainingTab", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		_p.addTab();
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone), 1);
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		var _c = _p.add(new UIButton("C", 0, 0, 50, 20, "c", blue_button00), -1);
		gt_assert_true(_b.getContainingPanel() == _p);
		gt_assert_true(_p.getContainingPanel() == _p);
		gt_assert_equal(_b.getContainingTab(), 1);
		gt_assert_equal(_c.getContainingTab(), -1);
		gt_assert_undefined(_p.getContainingTab());
	});

	_s.test("add to an out-of-range tab throws", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		gt_assert_throws(method({p: _p}, function() { p.add(new UIGroup("G", 0, 0, 1, 1, noone), 5); }));
	});

	_s.test("destroy: runs callback, removes from parent and registry, destroys children", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		var _flag = {called: false};
		_g.setOnDestroyCallback(method(_flag, function() { called = true; }));
		_g.destroy();
		gt_assert_true(_flag.called);
		gt_assert_false(ui_exists("G"));
		gt_assert_false(ui_exists("B"));
		gt_assert_equal(array_length(_p.getChildren()), 0);
	});

	_s.test("destroying a widget that was never added to a parent does not crash", function() {
		var _b = new UIButton("Lonely", 0, 0, 50, 20, "b", blue_button00);
		gt_assert_no_throw(method({b: _b}, function() { b.destroy(); }));
		gt_assert_false(ui_exists("Lonely"));
	});

	_s.test("destroying an unrelated widget does not cancel an ongoing drag", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _b = _p.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		global.__gooey_manager_active.__currentlyDraggedWidget = _p;
		_b.destroy();
		gt_assert_true(global.__gooey_manager_active.__currentlyDraggedWidget == _p);
	});

	_s.test("pre/post render callbacks fire on render, even when not visible (pre) ", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _f = {pre: 0, post: 0};
		_p.setPreRenderCallback(method(_f, function() { pre++; }));
		_p.setPostRenderCallback(method(_f, function() { post++; }));
		gt_render();
		gt_assert_equal(_f.pre, 1);
		gt_assert_equal(_f.post, 1);
	});

	_s.test("binding to a struct variable updates the widget on render", function() {
		var _data = {name: "hello"};
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _t = _p.add(new UIText("T", 0, 0, ""));
		_t.setBinding(_data, "name");
		gt_render();
		gt_assert_equal(_t.getText(), "hello");
		_data.name = "world";
		gt_render();
		gt_assert_equal(_t.getText(), "world");
		gt_assert_true(_t.getBinding() != undefined);
		_t.clearBinding();
		gt_assert_undefined(_t.getBinding());
	});

	_s.test("slider/checkbox/progressbar bindings read and write the bound variable", function() {
		var _data = {vol: 3, on: false, hp: 5};
		var _p = new UIPanel("P", 0, 0, 400, 300, grey_panel);
		var _sl = _p.add(new UISlider("S", 0, 0, 100, noone, yellow_circle, 0, 0, 10));
		_sl.setBinding(_data, "vol");
		var _cb = _p.add(new UICheckbox("C", 0, 40, "c", yellow_checkmark, yellow_cross, false));
		_cb.setBinding(_data, "on");
		var _pb = _p.add(new UIProgressBar("PB", 0, 80, grey_button00, yellow_circle, 0, 0, 10));
		_pb.setBinding(_data, "hp");
		gt_render();
		gt_assert_equal(_sl.getValue(), 3);
		gt_assert_equal(_pb.getValue(), 5);
		_cb.setValue(true);
		gt_assert_true(_data.on);
		_sl.setValue(8);
		gt_assert_equal(_data.vol, 8);
	});

	_s.test("binding to a method calls it", function() {
		var _data = {f: function() { return "from method"; }};
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _t = _p.add(new UIText("T", 0, 0, ""));
		_t.setBinding(_data, "f");
		gt_render();
		gt_assert_equal(_t.getText(), "from method");
	});

	_s.test("getChildrenBoundingBox: plain widgets", function() {
		var _p = new UIPanel("P", 100, 100, 400, 300, grey_panel);
		_p.add(new UIGroup("A", 10, 20, 50, 40, noone));
		_p.add(new UIGroup("B", 100, 5, 30, 30, noone));
		var _abs = _p.getChildrenBoundingBoxAbsolute();
		gt_assert_equal(_abs.x, 110);
		gt_assert_equal(_abs.y, 105);
		gt_assert_equal(_abs.width, 130 - 10);
		gt_assert_equal(_abs.height, 60 - 5);
		var _rel = _p.getChildrenBoundingBoxRelative();
		gt_assert_equal(_rel.x, 10);
		gt_assert_equal(_rel.y, 5);
	});

	_s.test("getChildrenBoundingBox: includes Text children without crashing", function() {
		var _p = new UIPanel("P", 100, 100, 400, 300, grey_panel);
		_p.add(new UIText("T", 10, 10, "hello world"));
		_p.add(new UIGroup("A", 200, 100, 10, 10, noone));
		var _box;
		gt_assert_no_throw(method({p: _p}, function() { var _a = p.getChildrenBoundingBoxAbsolute(); var _r = p.getChildrenBoundingBoxRelative(); }));
		_box = _p.getChildrenBoundingBoxAbsolute();
		gt_assert_true(_box.width >= 110, "box should span from the text to the group");
	});

	_s.test("getChildrenBoundingBox of an empty container is empty, not huge", function() {
		var _p = new UIPanel("P", 100, 100, 400, 300, grey_panel);
		var _box = _p.getChildrenBoundingBoxAbsolute();
		gt_assert_equal(_box.width, 0);
		gt_assert_equal(_box.height, 0);
	});

	_s.test("min width/height can be read back and are enforced as a lower bound of 1", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		_p.setMinWidth(150).setMinHeight(90);
		gt_assert_equal(_p.getMinWidth(), 150);
		gt_assert_equal(_p.getMinHeight(), 90);
		_p.setMinWidth(0);
		gt_assert_equal(_p.getMinWidth(), 1);
	});

	_s.test("interactable defaults: containers and text are not, buttons are", function() {
		gt_assert_false(new UIGroup("G", 0, 0, 1, 1, noone).getInteractable());
		gt_assert_false(new UIText("T", 0, 0, "x").getInteractable());
		gt_assert_true(new UIButton("B", 0, 0, 1, 1, "x", noone).getInteractable());
	});

	_s.test("find() locates descendants by ID", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _g = _p.add(new UIGroup("G", 0, 0, 100, 100, noone));
		var _b = _g.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		gt_assert_true(_p.find("B") == _b);
		gt_assert_equal(_p.find("zzz"), noone);
		gt_assert_equal(_g.find("P"), noone, "does not search upward");
	});

	_s.test("effective visibility/enabled take ancestors into account", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		var _b = _p.add(new UIButton("B", 0, 0, 50, 20, "b", blue_button00));
		_b.setVisible(true);
		_p.__visible = false;	// ancestor hidden without cascading
		gt_assert_false(_b.isEffectivelyVisible());
		_p.__visible = true;
		gt_assert_true(_b.isEffectivelyVisible());
		_p.__enabled = false;
		gt_assert_false(_b.isEffectivelyEnabled());
	});
}
