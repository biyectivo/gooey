/// @feather ignore all
/************************************************************************************
	gooey tests - option widgets (option group, dropdown, spinner), sprite, canvas,
	grid, group, utilities and the input seam
*************************************************************************************/

function gt_register_choice_widgets() {
	var _s = gt_suite("OptionGroup");

	_s.test("selection, VALUE_CHANGED, text getters", function() {
		var _og = new UIOptionGroup("O", 0, 0, ["[c_red]A", "B", "C"], yellow_circle, -1);
		var _r = {old: -9, new_: -9, n: 0};
		_og.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function(_o, _n) { old = _o; new_ = _n; n++; }));
		gt_assert_equal(_og.getIndex(), -1);
		gt_assert_equal(_og.getOptionText(), "");
		_og.setIndex(0);
		gt_assert_equal(_og.getOptionText(), "[c_red]A");
		gt_assert_equal(_og.getOptionRawText(), "A");
		gt_assert_equal(_r.old, -1);
		gt_assert_equal(_r.new_, 0);
		_og.setIndex(0);
		gt_assert_equal(_r.n, 1);
	});

	_s.test("setIndex clamps to the last valid option", function() {
		var _og = new UIOptionGroup("O", 0, 0, ["A", "B", "C"], yellow_circle, 0);
		_og.setIndex(99);
		gt_assert_equal(_og.getIndex(), 2);
		gt_assert_no_throw(method({o: _og}, function() { o.getOptionText(); }));
		_og.setIndex(-1);
		gt_assert_equal(_og.getIndex(), -1);
	});

	_s.test("clicking an option selects it", function() {
		var _p = gt_host_panel();
		var _og = _p.add(new UIOptionGroup("O", 30, 60, ["Alpha", "Beta", "Gamma"], yellow_circle, 0));
		gt_render();
		gt_render();	// second render: option rectangles from the first one are now available
		var _dim = _og.__option_array_dimensions[2];
		gt_mouse().moveTo(_dim.x + 5, _dim.y + 5);
		gt_frame();
		gt_mouse().press();
		gt_frame();
		gt_mouse().release();
		gt_frame();
		gt_assert_equal(_og.getIndex(), 2);
	});

	_s.test("option arrays are independent copies", function() {
		var _opts = ["A", "B"];
		var _og = new UIOptionGroup("O", 0, 0, _opts, yellow_circle, 0);
		_og.setOptionArraySelected(["a", "b"]);
		gt_assert_equal(_og.getOptionArrayUnselected(), ["A", "B"]);
		_opts[0] = "changed";
		gt_assert_equal(_og.getOptionArrayUnselected()[0], "A", "mutating the caller's array must not change the widget");
	});

	_s.test("vertical/horizontal layouts and spacing render", function() {
		var _p = gt_host_panel();
		var _og = _p.add(new UIOptionGroup("O", 30, 60, ["Alpha", "Beta", "Gamma"], yellow_circle, 1));
		gt_assert_no_throw(function() { gt_render(); });
		_og.setVertical(false).setSpacing(3);
		gt_assert_no_throw(function() { gt_render(); });
		gt_assert_false(_og.getVertical());
	});

	_s = gt_suite("Dropdown");

	_s.test("construction and selection", function() {
		var _dd = new UIDropdown("D", 0, 0, ["A", "B", "C"], grey_panel, grey_button00, -1);
		gt_assert_equal(_dd.getType(), UI_TYPE.DROPDOWN);
		gt_assert_equal(_dd.getIndex(), -1);
		_dd.setIndex(1);
		gt_assert_equal(_dd.getOptionRawText(), "B");
		_dd.setPlaceholderText("pick");
		gt_assert_equal(_dd.getPlaceholderText(), "pick");
	});

	_s.test("clicking opens and closes the list", function() {
		var _p = gt_host_panel();
		var _dd = _p.add(new UIDropdown("D", 30, 60, ["Alpha", "Beta", "Gamma"], grey_panel, grey_button00, 0));
		gt_render();
		gt_assert_false(_dd.isDropdownActive());
		gt_click(_dd);
		gt_assert_true(_dd.isDropdownActive());
		gt_click(_dd);
		gt_assert_false(_dd.isDropdownActive());
	});

	_s.test("clicking elsewhere closes an open list", function() {
		var _p = gt_host_panel();
		var _dd = _p.add(new UIDropdown("D", 30, 60, ["Alpha", "Beta", "Gamma"], grey_panel, grey_button00, 0));
		gt_render();
		gt_click(_dd);
		gt_assert_true(_dd.isDropdownActive());
		gt_mouse().moveTo(550, 450);
		gt_frame();
		gt_mouse().press();
		gt_frame();
		gt_mouse().release();
		gt_frame();
		gt_assert_false(_dd.isDropdownActive());
	});

	_s.test("Escape closes an open list", function() {
		var _p = gt_host_panel();
		var _dd = _p.add(new UIDropdown("D", 30, 60, ["Alpha", "Beta"], grey_panel, grey_button00, 0));
		gt_render();
		gt_click(_dd);
		gt_assert_true(_dd.isDropdownActive());
		gt_mouse().pressKey(vk_escape);
		gt_frame();
		gt_assert_false(_dd.isDropdownActive());
	});

	_s.test("renders closed, open and at 2x scale", function() {
		var _p = gt_host_panel();
		var _dd = _p.add(new UIDropdown("D", 30, 60, ["Alpha", "Beta", "Gamma"], grey_panel, grey_button00, 1));
		gt_assert_no_throw(function() { gt_render(); });
		gt_click(_dd);
		gt_assert_no_throw(function() { gt_render(); });
		ui_set_scale(2);
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s.test("paddings", function() {
		var _dd = new UIDropdown("D", 0, 0, ["A"], grey_panel, grey_button00, 0);
		_dd.setPaddings(7);
		gt_assert_equal(_dd.getPaddingTop(), 7);
		gt_assert_equal(_dd.getPaddingBottom(), 7);
		gt_assert_equal(_dd.getPaddingLeft(), 7);
		gt_assert_equal(_dd.getPaddingRight(), 7);
	});

	_s = gt_suite("Spinner");

	_s.test("construction exposes the inner buttons", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISpinner("Sp", 30, 60, ["A", "B", "C"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		gt_assert_equal(_sp.getType(), UI_TYPE.SPINNER);
		gt_assert_true(is_struct(_sp.getButtonLeft()));
		gt_assert_true(is_struct(_sp.getButtonRight()));
		gt_assert_true(is_struct(_sp.getButtonText()));
		gt_assert_equal(_sp.getIndex(), 0);
	});

	_s.test("right/left buttons cycle through the options and wrap", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISpinner("Sp", 30, 60, ["A", "B", "C"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		gt_render();
		gt_click(_sp.getButtonRight());
		gt_assert_equal(_sp.getIndex(), 1);
		gt_click(_sp.getButtonRight());
		gt_click(_sp.getButtonRight());
		gt_assert_equal(_sp.getIndex(), 0, "wraps forward");
		gt_click(_sp.getButtonLeft());
		gt_assert_equal(_sp.getIndex(), 2, "wraps backward");
	});

	_s.test("two spinners with the same ID drive their own selection", function() {
		var _p = gt_host_panel();
		var _a = _p.add(new UISpinner("Sp", 30, 60, ["A", "B", "C"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		var _b = _p.add(new UISpinner("Sp", 30, 160, ["X", "Y", "Z"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		gt_render();
		gt_click(_b.getButtonRight());
		gt_assert_equal(_b.getIndex(), 1);
		gt_assert_equal(_a.getIndex(), 0, "the first spinner must not react");
	});

	_s.test("an empty option list does not divide by zero", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISpinner("Sp", 30, 60, [], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		gt_render();
		gt_assert_no_throw(method({s: _sp}, function() { gt_click(s.getButtonRight()); gt_click(s.getButtonLeft()); }));
	});

	_s.test("VALUE_CHANGED fires and the text button follows the selection", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISpinner("Sp", 30, 60, ["A", "B"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		var _r = {n: 0};
		_sp.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { n++; }));
		_sp.setIndex(1);
		gt_render();
		gt_assert_equal(_r.n, 1);
		gt_assert_equal(_sp.getButtonText().getText(), "B");
	});
}

/// @function gt_anim_sprite()
/// @description a two-frame 32x32 sprite created at runtime, so the tests do not depend on any sprite of the demo project
function gt_anim_sprite() {
	static _spr = -1;
	if (!sprite_exists(_spr)) {
		var _surf = surface_create(32, 32);
		surface_set_target(_surf);
		draw_clear(c_white);
		surface_reset_target();
		_spr = sprite_create_from_surface(_surf, 0, 0, 32, 32, false, false, 0, 0);
		sprite_add_from_surface(_spr, _surf, 0, 0, 32, 32, false, false);
		surface_free(_surf);
	}
	return _spr;
}

function gt_register_misc_widgets() {
	var _s = gt_suite("Sprite");

	_s.test("defaults to the sprite size", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISprite("Sp", 10, 10, gooey));
		gt_render();
		gt_assert_equal(_sp.getDimensions().width, sprite_get_width(gooey));
		gt_assert_equal(_sp.getDimensions().height, sprite_get_height(gooey));
	});

	_s.test("can be created with no sprite", function() {
		gt_assert_no_throw(function() { var _sp = new UISprite("Sp", 0, 0, noone); });
		gt_assert_no_throw(function() { var _sp = new UISprite("Sp2", 0, 0, undefined); });
	});

	_s.test("animation can be started, paused, restarted and stopped with speed 0", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISprite("Sp", 10, 10, gt_anim_sprite()));
		_sp.setAnimationSpeed(10);
		gt_assert_true(time_source_exists(_sp.__time_source));
		gt_assert_equal(time_source_get_state(_sp.__time_source), time_source_state_active);
		_sp.animationPause();
		gt_assert_equal(time_source_get_state(_sp.__time_source), time_source_state_paused);
		_sp.animationStart();
		gt_assert_equal(time_source_get_state(_sp.__time_source), time_source_state_active);
		_sp.setAnimationSpeed(0);
		gt_assert_true(!time_source_exists(_sp.__time_source) || time_source_get_state(_sp.__time_source) != time_source_state_active, "speed 0 must stop the animation");
	});

	_s.test("destroying a sprite widget releases its time source", function() {
		var _sp = new UISprite("Sp", 10, 10, gt_anim_sprite());
		_sp.setAnimationSpeed(10);
		var _ts = _sp.__time_source;
		_sp.destroy();
		gt_assert_false(time_source_exists(_ts));
	});

	_s.test("angle, nine slice and animation accessors", function() {
		var _sp = new UISprite("Sp", 0, 0, gt_anim_sprite());
		_sp.setAngle(45).setUseNineSlice(false).setAnimationStep(-1).setAnimationLength(1).setAnimationStartingFrame(1);
		gt_assert_equal(_sp.getAngle(), 45);
		gt_assert_false(_sp.getUseNineSlice());
		gt_assert_equal(_sp.getAnimationStep(), -1);
		gt_assert_equal(_sp.getAnimationLength(), 1);
		gt_assert_equal(_sp.getAnimationStartingFrame(), 1);
	});

	_s.test("renders (nine-slice and plain)", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISprite("Sp", 10, 10, gt_anim_sprite(), 64, 32));
		gt_assert_no_throw(function() { gt_render(); });
		_sp.setUseNineSlice(false).setAngle(10);
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s = gt_suite("Canvas");

	_s.test("draws the surface; destroying the widget frees it by default", function() {
		var _surf = surface_create(40, 40);
		var _p = gt_host_panel();
		var _c = _p.add(new UICanvas("C", 10, 10, 80, 80, _surf));
		gt_assert_true(_c.getSurface() == _surf);
		gt_assert_no_throw(function() { gt_render(); });
		_c.destroy();
		gt_assert_false(surface_exists(_surf));
	});

	_s.test("a canvas that does not own the surface leaves it alive", function() {
		var _surf = surface_create(40, 40);
		var _c = new UICanvas("C", 10, 10, 80, 80, _surf);
		_c.setOwnsSurface(false);
		gt_assert_false(_c.getOwnsSurface());
		_c.destroy();
		gt_assert_true(surface_exists(_surf));
		surface_free(_surf);
	});

	_s.test("rendering a canvas whose surface was lost does not spam the log", function() {
		var _surf = surface_create(40, 40);
		var _p = gt_host_panel();
		var _c = _p.add(new UICanvas("C", 10, 10, 80, 80, _surf));
		surface_free(_surf);
		global.__gooey_manager_active.setLogMessageLevel(UI_MESSAGE_LEVEL.WARNING);
		var _before = global.__gooey_manager_active.__log_count;
		repeat (5) gt_render();
		gt_assert_true(global.__gooey_manager_active.__log_count - _before <= 1);
	});

	_s = gt_suite("Grid");

	_s.test("creates rows x columns cells and lays them out", function() {
		var _p = gt_host_panel(100, 100, 400, 300);
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		gt_assert_equal(_g.getRows(), 2);
		gt_assert_equal(_g.getColumns(), 2);
		var _c00 = _g.getCell(0, 0), _c11 = _g.getCell(1, 1);
		gt_assert_equal(_c00.getDimensions().x, 100);
		gt_assert_equal(_c00.getDimensions().width, 200);
		gt_assert_equal(_c00.getDimensions().height, 150);
		gt_assert_equal(_c11.getDimensions().x, 300);
		gt_assert_equal(_c11.getDimensions().y, 250);
	});

	_s.test("margins, spacing and proportions", function() {
		var _p = gt_host_panel(100, 100, 400, 300);
		var _g = _p.add(new UIGrid("Gr", 1, 2));
		_g.setMargins(10).setSpacingHorizontal(20).setColumnProportions([0.25, 0.75]);
		var _a = _g.getCell(0, 0), _b = _g.getCell(0, 1);
		var _usable = 400 - 20 - 20;
		gt_assert_near(_a.getDimensions().x, 110);
		gt_assert_near(_a.getDimensions().width, 0.25 * _usable);
		gt_assert_near(_b.getDimensions().x, 110 + 0.25 * _usable + 20);
		gt_assert_near(_b.getDimensions().width, 0.75 * _usable);
		gt_assert_near(_a.getDimensions().height, 300 - 20);
	});

	_s.test("addToCell places the widget in the cell; addNext fills in reading order", function() {
		var _p = gt_host_panel(100, 100, 400, 300);
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		var _a = _g.addNext(new UIGroup("A", 0, 0, 5, 5, noone));
		var _b = _g.addNext(new UIGroup("B", 0, 0, 5, 5, noone));
		var _c = _g.addNext(new UIGroup("C", 0, 0, 5, 5, noone));
		gt_assert_true(_a.getParent() == _g.getCell(0, 0));
		gt_assert_true(_b.getParent() == _g.getCell(0, 1));
		gt_assert_true(_c.getParent() == _g.getCell(1, 0));
		var _d = _g.addNextRow(new UIGroup("D", 0, 0, 5, 5, noone));
		gt_assert_true(_d.getParent() == _g.getCell(0, 0), "next row wraps to the first row of the same column");
	});

	_s.test("addToCell validates the indices and rejects panels", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		gt_assert_throws(method({g: _g}, function() { g.addToCell(new UIGroup("A", 0, 0, 1, 1, noone), 2, 0); }));
		gt_assert_throws(method({g: _g}, function() { g.addToCell(new UIGroup("B", 0, 0, 1, 1, noone), 0, -1); }));
		gt_assert_throws(method({g: _g}, function() { g.addToCell(new UIPanel("Q", 0, 0, 1, 1, noone), 0, 0); }));
	});

	_s.test("wrong proportion list sizes are rejected without corrupting the grid", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		_g.setColumnProportions([0.3, 0.3, 0.4]);
		gt_assert_equal(array_length(_g.getColumnProportions()), 2);
		gt_assert_no_throw(method({g: _g}, function() { g.getCell(1, 1).getDimensions(); }));
	});

	_s.test("a grid whose ID was renamed (duplicate) still works", function() {
		var _p = gt_host_panel();
		var _g1 = _p.add(new UIGrid("Gr", 1, 1));
		var _g2 = _p.add(new UIGrid("Gr", 1, 1));
		gt_assert_equal(_g2.getID(), "Gr1");
		var _cell = _g2.getCell(0, 0);
		gt_assert_true(is_struct(_cell));
		gt_assert_no_throw(method({g: _g2}, function() { g.addToCell(new UIGroup("Z", 0, 0, 5, 5, noone), 0, 0); }));
	});

	_s.test("destroying a grid destroys its cells and their content", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		_g.addToCell(new UIGroup("Inside", 0, 0, 5, 5, noone), 1, 1);
		_g.destroy();
		gt_assert_false(ui_exists("Inside"));
		gt_assert_false(ui_exists("Gr_CellGroup_1_1"));
	});

	_s.test("under UI scale the cells still tile the grid exactly", function() {
		ui_set_scale(2);
		var _p = gt_host_panel(100, 100, 400, 300);
		var _g = _p.add(new UIGrid("Gr", 1, 2));
		var _a = _g.getCell(0, 0), _b = _g.getCell(0, 1);
		var _drawn_a = _a.getDimensions().width * 2;
		var _drawn_b = _b.getDimensions().width * 2;
		gt_assert_near(_drawn_a + _drawn_b, _g.getDimensions().width * 2, 0.01);
		gt_assert_near(_b.getDimensions().x, _a.getDimensions().x + _drawn_a, 0.01);
	});

	_s.test("grid overlay and clipping flags", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGrid("Gr", 2, 2));
		_g.setShowGridOverlay(true).setCellsClipContents(true);
		gt_assert_true(_g.getShowGridOverlay());
		gt_assert_true(_g.getCellsClipContents());
		gt_assert_true(_g.getCell(0, 0).getClipsContent());
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s = gt_suite("Group");

	_s.test("groups are non-interactive containers and render", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGroup("G", 10, 10, 100, 100, grey_panel));
		_g.add(new UIButton("B", 5, 5, 50, 20, "x", blue_button00));
		gt_assert_false(_g.getInteractable());
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s.test("a clipping group still lets you reach children inside the clip area", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGroup("G", 10, 60, 200, 100, noone));
		_g.setClipsContent(true);
		var _b = _g.add(new UIButton("B", 10, 10, 100, 30, "x", blue_button00));
		var _r = {n: 0};
		_b.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { n++; }));
		gt_click(_b);
		gt_assert_equal(_r.n, 1);
	});
}

function gt_register_utilities() {
	var _s = gt_suite("Utilities");

	_s.test("sprite_scale returns a scaled copy", function() {
		var _spr = sprite_scale(grey_panel, 0, 2);
		gt_assert_true(sprite_exists(_spr));
		gt_assert_equal(sprite_get_width(_spr), 200);
		gt_assert_equal(sprite_get_height(_spr), 200);
		sprite_delete(_spr);
		var _spr2 = sprite_scale(grey_panel, 0, 0.5, 3);
		gt_assert_equal(sprite_get_width(_spr2), 50);
		gt_assert_equal(sprite_get_height(_spr2), 300);
		sprite_delete(_spr2);
	});

	_s.test("sprite_scale rejects invalid input", function() {
		gt_assert_undefined(sprite_scale(noone, 0, 2));
		gt_assert_undefined(sprite_scale(grey_panel, 0, 0));
		gt_assert_undefined(sprite_scale(grey_panel, 0, -1));
	});

	_s.test("sprite_scale keeps the nine-slice flag", function() {
		var _src = sprite_get_nineslice(grey_panel);
		var _spr = sprite_scale(grey_panel, 0, 2);
		gt_assert_equal(sprite_get_nineslice(_spr).enabled, _src.enabled);
		sprite_delete(_spr);
	});

	_s.test("text_renderer fallback implements the Scribble surface the library needs", function() {
		var _t = new text_renderer("hello");
		gt_assert_equal(_t.get_text(), "hello");
		gt_assert_true(_t.get_width() > 0);
		gt_assert_true(is_callable(_t.wrap));
		gt_assert_true(is_callable(_t.get_bbox));
		var _b = _t.get_bbox(10, 10);
		gt_assert_true(_b.right > _b.left);
		gt_assert_true(_b.bottom > _b.top);
	});

	_s.test("convenience functions mirror the manager", function() {
		var _p = new UIPanel("P", 0, 0, 100, 100, grey_panel);
		gt_assert_true(ui_get_widgets() == global.__gooey_manager_active.getWidgets());
		gt_assert_true(ui_get_panels()[0] == _p);
		ui_set_cursor(cr_default);
		ui_set_camera(undefined);
		gt_assert_equal(ui_get_currently_dragged_widget(), undefined);
		gt_assert_equal(ui_get_currently_hovered_widget(), undefined);
		gt_assert_equal(ui_get_currently_hovered_panel(), undefined);
	});

	_s.test("cursor is applied once per change, not re-set every frame (flicker fix)", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _ui = global.__gooey_manager_active;
		gt_hover(_b);
		gt_frame(2);
		gt_assert_equal(_ui.__cursor_applied, UI_CURSOR_INTERACT);
		// Stay on the button: the OS cursor must not be touched again
		window_set_cursor(cr_arrow);	// sentinel; would be overwritten if the library re-applied every frame
		gt_frame(5);
		gt_assert_equal(window_get_cursor(), cr_arrow);
		gt_assert_equal(_ui.__cursor_applied, UI_CURSOR_INTERACT);
		// Sprite cursors: native cursor hidden, sprite assigned, stable across frames
		ui_set_cursor(yellow_circle);
		gt_assert_equal(cursor_sprite, yellow_circle);
		gt_assert_equal(window_get_cursor(), cr_none);
		ui_set_cursor(cr_default);
		gt_assert_equal(cursor_sprite, -1);
	});

	_s.test("input provider overrides are used by the widgets and removing it restores native input", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		gt_hover(_b);
		gt_assert_true(_b.__events_fired[UI_EVENT.MOUSE_OVER]);
		ui_set_input_provider({mouse_x: function(_d) { return -999; }, mouse_y: function(_d) { return -999; }});
		gt_frame();
		gt_assert_false(_b.__events_fired[UI_EVENT.MOUSE_OVER]);
		ui_set_input_provider(undefined);
		gt_assert_undefined(ui_get_input_provider());
	});

	_s.test("a provider with missing callbacks falls back to native input for them", function() {
		ui_set_input_provider({});
		gt_assert_no_throw(function() { __gooey_mouse_x(0); __gooey_mouse_down(0, mb_left); __gooey_key_down(vk_space); __gooey_wheel_up(); });
	});

	_s.test("log level filtering", function() {
		var _ui = global.__gooey_manager_active;
		_ui.setLogMessageLevel(UI_MESSAGE_LEVEL.ERROR);
		var _n = _ui.__log_count;
		_ui.__logMessage("info", UI_MESSAGE_LEVEL.INFO);
		gt_assert_equal(_ui.__log_count, _n);
		_ui.__logMessage("err", UI_MESSAGE_LEVEL.ERROR);
		gt_assert_equal(_ui.__log_count, _n + 1);
	});
}

function gt_register_new_api() {
	var _s = gt_suite("ToggleButton");

	_s.test("toggles on click and fires VALUE_CHANGED", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UIToggleButton("T", 50, 60, 120, 40, "tool", blue_button00, grey_button00, false));
		var _r = {old: undefined, new_: undefined, n: 0};
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function(_o, _n) { old = _o; new_ = _n; n++; }));
		gt_assert_equal(_t.getType(), UI_TYPE.TOGGLE_BUTTON);
		gt_assert_false(_t.getValue());
		gt_click(_t);
		gt_assert_true(_t.getValue());
		gt_assert_equal(_r.old, false);
		gt_assert_equal(_r.new_, true);
		gt_click(_t);
		gt_assert_false(_t.getValue());
		gt_assert_equal(_r.n, 2);
	});

	_s.test("setValue only notifies on change; chaining", function() {
		var _t = new UIToggleButton("T", 0, 0, 100, 30, "x", blue_button00);
		var _r = {n: 0};
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { n++; }));
		gt_assert_true(_t.setValue(true) == _t);
		_t.setValue(true);
		gt_assert_equal(_r.n, 1);
		_t.toggle();
		gt_assert_false(_t.getValue());
		gt_assert_equal(_t.getSpriteOn(), blue_button00, "on sprite defaults to the off sprite");
	});

	_s.test("keeps button behavior (callbacks, text) and writes to its binding", function() {
		var _data = {on: false};
		var _p = gt_host_panel();
		var _t = _p.add(new UIToggleButton("T", 50, 60, 120, 40, "tool", blue_button00, grey_button00));
		_t.setBinding(_data, "on");
		var _r = {rel: 0};
		_t.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { rel++; }));
		gt_click(_t);
		gt_assert_equal(_r.rel, 1);
		gt_assert_true(_data.on);
		_data.on = false;
		gt_render();
		gt_assert_false(_t.getValue());
		gt_assert_equal(_t.getRawText(), "tool");
	});

	_s.test("renders in both states, with an alternate text", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UIToggleButton("T", 50, 60, 120, 40, "off", blue_button00, grey_button00));
		_t.setTextOn("on");
		gt_assert_no_throw(function() { gt_render(); });
		_t.setValue(true);
		gt_assert_no_throw(function() { gt_render(); });
		gt_assert_equal(_t.getText(), "off", "drawing must not leave the 'on' text behind");
		gt_assert_equal(_t.getSprite(), blue_button00);
	});

	_s = gt_suite("New API");

	_s.test("panel show / hide / toggle", function() {
		var _p = new UIPanel("P", 0, 0, 100, 100, grey_panel);
		_p.hide();
		gt_assert_false(_p.getVisible());
		_p.show();
		gt_assert_true(_p.getVisible());
		_p.toggle();
		gt_assert_false(_p.getVisible());
	});

	_s.test("panel centerOnScreen", function() {
		var _p = new UIPanel("P", 5, 5, 200, 100, grey_panel);
		var _b = _p.add(new UIGroup("G", 10, 10, 10, 10, noone));
		_p.centerOnScreen();
		gt_assert_near(_p.getDimensions().x, (display_get_gui_width() - 200) / 2);
		gt_assert_near(_p.getDimensions().y, (display_get_gui_height() - 100) / 2);
		gt_assert_near(_b.getDimensions().x, _p.getDimensions().x + 10);
		_p.setDimensions(,, 220);
		gt_assert_near(_p.getDimensions().x, (display_get_gui_width() - 200) / 2, 0.01, "a later relayout keeps the new position");
	});

	_s.test("widget bounding box follows the UI scale; hovered/pressed state", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 100, 40, "b", blue_button00));
		var _box = _b.getBoundingBox();
		gt_assert_equal(_box.width, 100);
		ui_set_scale(2);
		gt_assert_equal(_b.getBoundingBox().width, 200);
		gt_assert_equal(_b.getBoundingBox().height, 80);
		gt_assert_false(_b.isHovered());
		gt_hover(_b);
		gt_assert_true(_b.isHovered());
		gt_assert_false(_b.isPressed());
		gt_mouse().press();
		gt_frame();
		gt_assert_true(_b.isPressed());
	});

	_s.test("spinner without wrapping stops at the ends", function() {
		var _p = gt_host_panel();
		var _sp = _p.add(new UISpinner("Sp", 30, 60, ["A", "B"], grey_button00, yellow_sliderLeft, yellow_sliderRight, 220, 40, 0));
		_sp.setWrap(false);
		gt_assert_false(_sp.getWrap());
		gt_render();
		gt_click(_sp.getButtonLeft());
		gt_assert_equal(_sp.getIndex(), 0);
		gt_click(_sp.getButtonRight());
		gt_click(_sp.getButtonRight());
		gt_assert_equal(_sp.getIndex(), 1);
	});

	_s.test("manager queries: modal panel, hovered panel/widget, bring to front / send to back", function() {
		var _ui = global.__gooey_manager_active;
		var _a = new UIPanel("A", 100, 100, 200, 200, grey_panel);
		var _b = new UIPanel("B", 400, 100, 200, 200, grey_panel);
		gt_assert_false(_ui.isModalOpen());
		gt_assert_equal(_ui.getModalPanel(), noone);
		_a.setModal(true);
		gt_assert_true(ui_is_modal_open());
		gt_assert_true(_ui.getModalPanel() == _a);
		_a.setModal(false);
		_ui.sendToBack("B");
		gt_assert_true(ui_get_focused_panel() == _a);
		_ui.bringToFront("B");
		gt_assert_true(ui_get_focused_panel() == _b);
		gt_mouse().moveTo(450, 150);
		gt_frame();
		gt_assert_true(_ui.getHoveredPanel() == _b);
		gt_assert_equal(ui_get_widget_count(), array_length(ui_get_widgets()));
	});

	_s.test("camera accessors", function() {
		var _cam = camera_create();
		ui_set_camera(_cam);
		gt_assert_equal(ui_get_camera(), _cam);
		ui_set_camera(undefined);
		camera_destroy(_cam);
	});
}

function gooey_register_all_tests() {
	global.__gt.suites = [];
	gt_register_manager();
	gt_register_positioning();
	gt_register_widget_base();
	gt_register_panel();
	gt_register_events();
	gt_register_basic_widgets();
	gt_register_textbox();
	gt_register_slider_progress();
	gt_register_choice_widgets();
	gt_register_misc_widgets();
	gt_register_utilities();
	gt_register_new_api();
	gt_register_bench();
}
