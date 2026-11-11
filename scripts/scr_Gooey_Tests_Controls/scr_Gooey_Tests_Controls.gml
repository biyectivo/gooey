/// @feather ignore all
/************************************************************************************
	gooey tests - events + individual widgets
*************************************************************************************/

/// helper: a roomy panel to host a widget under test
function gt_host_panel(_x = 100, _y = 100, _w = 500, _h = 400) {
	var _p = new UIPanel("Host", _x, _y, _w, _h, grey_panel);
	_p.setResizeBorderWidth(0);
	_p.setDragBarHeight(0);
	return _p;
}

function gt_register_events() {
	var _s = gt_suite("Events");

	_s.test("mouse enter / over / exit callbacks", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {enter: 0, over: 0, leave: 0};
		_b.setCallback(UI_EVENT.MOUSE_ENTER, method(_r, function() { enter++; }));
		_b.setCallback(UI_EVENT.MOUSE_OVER, method(_r, function() { over++; }));
		_b.setCallback(UI_EVENT.MOUSE_EXIT, method(_r, function() { leave++; }));
		gt_hover(_b);
		gt_assert_equal(_r.enter, 1);
		gt_assert_equal(_r.over, 1);
		gt_frame(2);
		gt_assert_equal(_r.enter, 1, "enter fires once");
		gt_assert_equal(_r.over, 3, "over fires every frame");
		gt_mouse().moveTo(-50, -50);
		gt_frame();
		gt_assert_equal(_r.leave, 1);
		gt_frame();
		gt_assert_equal(_r.leave, 1, "exit fires once");
	});

	_s.test("left click / hold / release", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {click: 0, hold: 0, rel: 0};
		_b.setCallback(UI_EVENT.LEFT_CLICK, method(_r, function() { click++; }));
		_b.setCallback(UI_EVENT.LEFT_HOLD, method(_r, function() { hold++; }));
		_b.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { rel++; }));
		gt_hover(_b);
		gt_mouse().press();
		gt_frame();
		gt_assert_equal(_r.click, 1);
		gt_assert_equal(_r.hold, 1);
		gt_frame(2);
		gt_assert_equal(_r.click, 1, "click fires only on the press frame");
		gt_assert_equal(_r.hold, 3);
		gt_mouse().release();
		gt_frame();
		gt_assert_equal(_r.rel, 1);
	});

	_s.test("right and middle buttons", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {rc: 0, mc: 0, rr: 0, mr: 0};
		_b.setCallback(UI_EVENT.RIGHT_CLICK, method(_r, function() { rc++; }));
		_b.setCallback(UI_EVENT.MIDDLE_CLICK, method(_r, function() { mc++; }));
		_b.setCallback(UI_EVENT.RIGHT_RELEASE, method(_r, function() { rr++; }));
		_b.setCallback(UI_EVENT.MIDDLE_RELEASE, method(_r, function() { mr++; }));
		gt_click(_b, mb_right);
		gt_click(_b, mb_middle);
		gt_assert_equal(_r.rc, 1);
		gt_assert_equal(_r.mc, 1);
		gt_assert_equal(_r.rr, 1);
		gt_assert_equal(_r.mr, 1);
	});

	_s.test("mouse wheel events", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {up: 0, down: 0};
		_b.setCallback(UI_EVENT.MOUSE_WHEEL_UP, method(_r, function() { up++; }));
		_b.setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, method(_r, function() { down++; }));
		gt_hover(_b);
		gt_mouse().scrollUp();
		gt_frame();
		gt_mouse().scrollDown();
		gt_frame();
		gt_assert_equal(_r.up, 1);
		gt_assert_equal(_r.down, 1);
	});

	_s.test("disabled and hidden widgets receive no events", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {click: 0};
		_b.setCallback(UI_EVENT.LEFT_CLICK, method(_r, function() { click++; }));
		_b.setEnabled(false);
		gt_click(_b);
		gt_assert_equal(_r.click, 0);
		_b.setEnabled(true).setVisible(false);
		gt_click(_b);
		gt_assert_equal(_r.click, 0);
		_b.setVisible(true);
		gt_click(_b);
		gt_assert_equal(_r.click, 1);
	});

	_s.test("a covered widget does not get the click (topmost sibling does)", function() {
		var _p = gt_host_panel();
		var _a = _p.add(new UIButton("A", 50, 60, 120, 40, "a", blue_button00));
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {a: 0, b: 0};
		_a.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { a++; }));
		_b.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { b++; }));
		gt_click(_a);
		gt_assert_equal(_r.a, 0);
		gt_assert_equal(_r.b, 1);
	});

	_s.test("widgets inside a clipping parent cannot be hit outside the clip area", function() {
		var _p = gt_host_panel(100, 100, 300, 200);
		var _b = _p.add(new UIButton("B", 250, 100, 200, 40, "b", blue_button00));	// sticks out of the panel (x: 350..550, panel ends at 400)
		var _r = {click: 0};
		_b.setCallback(UI_EVENT.LEFT_CLICK, method(_r, function() { click++; }));
		gt_mouse().moveTo(500, 220);
		gt_frame();
		gt_mouse().press();
		gt_frame();
		gt_assert_equal(_r.click, 0);
	});

	_s.test("drill-through: a child without its own callback forwards to the parent", function() {
		var _p = gt_host_panel();
		var _g = _p.add(new UIGroup("G", 20, 20, 300, 200, noone));
		var _b = _g.add(new UIButton("B", 10, 10, 120, 40, "b", blue_button00));
		var _r = {g: 0};
		_g.setCallback(UI_EVENT.LEFT_RELEASE, method(_r, function() { g++; }));
		gt_click(_b);
		gt_assert_equal(_r.g, 0, "no drill-through by default for left release");
		_b.setDrillThroughLeftRelease(true);
		gt_click(_b);
		gt_assert_equal(_r.g, 1);
	});

	_s.test("mouse wheel drills through by default (config macro)", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		var _r = {n: 0};
		_p.setCallback(UI_EVENT.MOUSE_WHEEL_UP, method(_r, function() { n++; }));
		gt_hover(_b);
		gt_mouse().scrollUp();
		gt_frame();
		gt_assert_equal(_r.n, 1);
	});

	_s.test("UI scale: hit testing follows the drawn (scaled) size", function() {
		ui_set_scale(2);
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 100, 40, "b", blue_button00));
		var _d = _b.getDimensions();
		var _r = {over: 0};
		_b.setCallback(UI_EVENT.MOUSE_OVER, method(_r, function() { over++; }));
		gt_mouse().moveTo(_d.x + 150, _d.y + 60);	// inside 2x size (200x80) but outside logical size (100x40)
		gt_frame();
		gt_assert_equal(_r.over, 1);
	});
}

function gt_register_basic_widgets() {
	var _s = gt_suite("Button");

	_s.test("text, states and formats", function() {
		var _b = new UIButton("B", 0, 0, 100, 30, "[c_red]Hi", blue_button00);
		gt_assert_equal(_b.getText(), "[c_red]Hi");
		gt_assert_equal(_b.getRawText(), "Hi");
		_b.setText("Yo", true);
		gt_assert_equal(_b.getTextMouseover(), "Yo");
		gt_assert_equal(_b.getTextClick(), "Yo");
		gt_assert_equal(_b.getTextDisabled(), "Yo");
		_b.setTextFormat("[c_blue]", true);
		gt_assert_equal(_b.getTextFormatDisabled(), "[c_blue]");
		_b.setSprite(grey_button00, true);
		gt_assert_equal(_b.getSpriteClick(), grey_button00);
		_b.setImage(1, true);
		gt_assert_equal(_b.getImageMouseover(), 1);
		gt_assert_equal(_b.getImageDisabled(), 1);
	});

	_s.test("text anchor and offset", function() {
		var _b = new UIButton("B", 0, 0, 100, 30, "x", blue_button00);
		_b.setTextRelativeTo(UI_RELATIVE_TO.TOP_LEFT).setTextOffset({x: 3, y: 4});
		gt_assert_equal(_b.getTextRelativeTo(), UI_RELATIVE_TO.TOP_LEFT);
		gt_assert_equal(_b.getTextOffset().x, 3);
	});

	_s.test("renders without error in every state", function() {
		var _p = gt_host_panel();
		var _b = _p.add(new UIButton("B", 50, 60, 120, 40, "b", blue_button00));
		gt_assert_no_throw(function() { gt_render(); });
		gt_hover(_b);
		gt_assert_no_throw(function() { gt_render(); });
		gt_mouse().press();
		gt_frame();
		gt_assert_no_throw(function() { gt_render(); });
		_b.setEnabled(false);
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s = gt_suite("Text");

	_s.test("text, raw text and formats", function() {
		var _t = new UIText("T", 0, 0, "[c_red]Hello");
		gt_assert_equal(_t.getText(), "[c_red]Hello");
		gt_assert_equal(_t.getRawText(), "Hello");
		_t.setText("Bye", true);
		gt_assert_equal(_t.getTextMouseover(), "Bye");
		gt_assert_equal(_t.getTextClick(), "Bye");
		_t.setTextFormat("[fa_left]", true);
		gt_assert_equal(_t.getTextFormatClick(), "[fa_left]");
	});

	_s.test("width and height reflect the text; max width wraps", function() {
		var _t = new UIText("T", 0, 0, "the quick brown fox jumps over the lazy dog");
		var _w = _t.getTextWidth();
		var _h = _t.getTextHeight();
		gt_assert_true(_w > 0 && _h > 0);
		_t.setMaxWidth(_w / 3);
		gt_assert_true(_t.getTextWidth() <= _w / 3 + 1);
		gt_assert_true(_t.getTextHeight() > _h);
	});

	_s.test("colors, alpha and blend modes", function() {
		var _t = new UIText("T", 0, 0, "x");
		_t.setBackgroundColor(c_red).setBackgroundAlpha(0.5).setBorderColor(c_blue);
		gt_assert_equal(_t.getBackgroundColor(), c_red);
		gt_assert_equal(_t.getBackgroundAlpha(), 0.5);
		gt_assert_equal(_t.getBorderColor(), c_blue);
		_t.setSourceBlendmode(bm_one).setDestBlendmode(bm_zero).setForceBlendmode(true);
		gt_assert_equal(_t.getSourceBlendmode(), bm_one);
		gt_assert_equal(_t.getDestBlendmode(), bm_zero);
		gt_assert_true(_t.getForceBlendmode());
	});

	_s.test("typist getter returns the typist that was set", function() {
		var _t = new UIText("T", 0, 0, "x");
		var _typist = scribble_typist();
		_t.setTypist(_typist);
		gt_assert_true(_t.getTypist() == _typist);
	});

	_s.test("renders inside a panel", function() {
		var _p = gt_host_panel();
		_p.add(new UIText("T", 10, 10, "text"));
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s = gt_suite("Checkbox");

	_s.test("value, toggle and VALUE_CHANGED", function() {
		var _c = new UICheckbox("C", 0, 0, "opt", yellow_checkmark, yellow_cross, false);
		var _r = {old: undefined, new_: undefined, n: 0};
		_c.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function(_o, _n) { old = _o; new_ = _n; n++; }));
		gt_assert_false(_c.getValue());
		_c.toggle();
		gt_assert_true(_c.getValue());
		gt_assert_equal(_r.old, false);
		gt_assert_equal(_r.new_, true);
		_c.setValue(true);
		gt_assert_equal(_r.n, 1, "no event when the value does not change");
	});

	_s.test("clicking toggles the value", function() {
		var _p = gt_host_panel();
		var _c = _p.add(new UICheckbox("C", 30, 60, "opt", yellow_checkmark, yellow_cross, false));
		gt_render();
		gt_click(_c);
		gt_assert_true(_c.getValue());
		gt_click(_c);
		gt_assert_false(_c.getValue());
	});

	_s.test("size is known from the sprites right after creation (clickable before the first draw)", function() {
		var _p = gt_host_panel();
		var _c = _p.add(new UICheckbox("C", 30, 60, "opt", yellow_checkmark, yellow_cross, false));
		gt_assert_true(_c.getDimensions().width > 0);
		gt_assert_true(_c.getDimensions().height > 0);
	});

	_s.test("text/sprite/image accessors", function() {
		var _c = new UICheckbox("C", 0, 0, "opt", yellow_checkmark, yellow_cross, false);
		gt_assert_equal(_c.getTextTrue(), "opt");
		_c.setTextTrue("on").setTextFalse("off");
		gt_assert_equal(_c.getRawTextTrue(), "on");
		gt_assert_equal(_c.getRawTextFalse(), "off");
		_c.setSpriteBase(grey_button00).setImageBase(3);
		gt_assert_equal(_c.getSpriteBase(), grey_button00);
		gt_assert_equal(_c.getImageBase(), 3);
		_c.setImageTrue(1).setImageFalse(2);
		gt_assert_equal(_c.getImageTrue(), 1);
		gt_assert_equal(_c.getImageFalse(), 2);
	});

	_s.test("renders in both states", function() {
		var _p = gt_host_panel();
		var _c = _p.add(new UICheckbox("C", 30, 60, "opt", yellow_checkmark, yellow_cross, false));
		gt_assert_no_throw(function() { gt_render(); });
		_c.setValue(true);
		gt_assert_no_throw(function() { gt_render(); });
	});
}

function gt_register_textbox() {
	var _s = gt_suite("TextBox");

	_s.test("text, placeholder and max chars", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00, 5);
		_t.setText("abcdefgh");
		gt_assert_equal(_t.getText(), "abcde");
		gt_assert_equal(_t.getMaxChars(), 5);
		_t.setPlaceholderText("type...");
		gt_assert_equal(_t.getPlaceholderText(), "type...");
		_t.setMaxChars(3);
		gt_assert_equal(_t.getText(), "abc");
	});

	_s.test("unlimited max chars", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		var _long = string_repeat("x", 3000);
		_t.setText(_long);
		gt_assert_equal(string_length(_t.getText()), 3000);
		_t.setMaxChars(0);
		gt_assert_equal(string_length(_t.getText()), 3000);
	});

	_s.test("setText fires VALUE_CHANGED only when the text changes", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		var _r = {old: "?", new_: "?", n: 0};
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function(_o, _n) { old = _o; new_ = _n; n++; }));
		_t.setText("a");
		_t.setText("a");
		gt_assert_equal(_r.n, 1);
		gt_assert_equal(_r.old, "");
		gt_assert_equal(_r.new_, "a");
	});

	_s.test("setMaxChars truncation also notifies and updates a binding", function() {
		var _data = {txt: ""};
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		_t.setBinding(_data, "txt");
		_t.setText("abcdef");
		var _r = {n: 0};
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { n++; }));
		_t.setMaxChars(2);
		gt_assert_equal(_t.getText(), "ab");
		gt_assert_equal(_r.n, 1);
		gt_assert_equal(_data.txt, "ab");
	});

	_s.test("read-only blocks user editing but not setText()", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		_t.setReadOnly(true);
		_t.setText("from code");
		gt_assert_equal(_t.getText(), "from code");
		_t.setCurrentlyEditing(true);
		gt_assert_false(_t.getCurrentlyEditing());
	});

	_s.test("clicking starts editing, typing updates the text", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		gt_render();
		gt_click(_t);
		gt_assert_true(_t.getCurrentlyEditing());
		keyboard_string = "hello";
		gt_frame();
		gt_assert_equal(_t.getText(), "hello");
	});

	_s.test("clicking outside stops editing", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		gt_render();
		gt_click(_t);
		gt_assert_true(_t.getCurrentlyEditing());
		gt_mouse().moveTo(900, 600);
		gt_frame();
		gt_mouse().press();
		gt_frame();
		gt_assert_false(_t.getCurrentlyEditing());
	});

	_s.test("input filters apply to typed characters", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		_t.setAllowLowercaseLetters(false).setAllowSpaces(false).setAllowSymbols(false);
		gt_render();
		gt_click(_t);
		keyboard_string = "aB 1-c2";
		gt_frame();
		gt_assert_equal(_t.getText(), "B12");
	});

	_s.test("text longer than the 1024-char keyboard_string limit survives editing", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		_t.setText(string_repeat("x", 1500));
		gt_render();
		gt_click(_t);
		gt_frame(2);
		gt_assert_equal(string_length(_t.getText()), 1500);
	});

	_s.test("Enter ends editing and fires SUBMIT (not VALUE_CHANGED)", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		_t.setText("abc");
		_t.setEnterFiresValueChanged(false);
		var _r = {submit: 0, changed: 0, text: ""};
		_t.setCallback(UI_EVENT.SUBMIT, method({r: _r, t: _t}, function() { r.submit++; r.text = t.getText(); }));
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { changed++; }));
		gt_render();
		gt_click(_t);
		var _changes = _r.changed;
		gt_mouse().pressKey(vk_enter);
		gt_render();
		gt_assert_equal(_r.submit, 1);
		gt_assert_equal(_r.text, "abc");
		gt_assert_equal(_r.changed, _changes, "enter must not look like a value change");
		gt_assert_false(_t.getCurrentlyEditing());
	});

	_s.test("Enter still fires VALUE_CHANGED by default (backwards compatibility)", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		_t.setText("abc");
		var _r = {changed: 0};
		_t.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { changed++; }));
		gt_render();
		gt_click(_t);
		gt_mouse().pressKey(vk_enter);
		gt_render();
		gt_assert_equal(_r.changed, 1);
	});

	_s.test("the text margin is added around the requested size (documented behavior)", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		gt_assert_equal(_t.getDimensions().width, 200 + 2 * _t.getTextMargin());
		gt_assert_equal(_t.getDimensions().height, 30 + 2 * _t.getTextMargin());
	});

	_s.test("clearText", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		_t.setText("abc");
		_t.clearText();
		gt_assert_equal(_t.getText(), "");
		gt_assert_equal(_t.getCursorPos(), -1);
	});

	_s.test("mask text renders", function() {
		var _p = gt_host_panel();
		var _t = _p.add(new UITextBox("T", 30, 80, 250, 30, grey_button00));
		_t.setText("secret").setMaskText(true);
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s.test("accessors", function() {
		var _t = new UITextBox("T", 0, 0, 200, 30, grey_button00);
		_t.setMultiline(true).setTextMargin(4).setCursorChar("_").setCursorColor("[c_red]").setMaskChar("#").setSymbolsAllowed("-");
		gt_assert_true(_t.getMultiline());
		gt_assert_equal(_t.getTextMargin(), 4);
		gt_assert_equal(_t.getCursorChar(), "_");
		gt_assert_equal(_t.getCursorColor(), "[c_red]");
		gt_assert_equal(_t.getMaskChar(), "#");
		gt_assert_equal(_t.getSymbolsAllowed(), "-");
	});
}

function gt_register_slider_progress() {
	var _s = gt_suite("Slider");

	_s.test("value is clamped to [min, max] and fires VALUE_CHANGED", function() {
		var _sl = new UISlider("S", 0, 0, 200, noone, yellow_circle, 5, 0, 10);
		var _r = {n: 0, old: -1, new_: -1};
		_sl.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function(_o, _n) { n++; old = _o; new_ = _n; }));
		_sl.setValue(50);
		gt_assert_equal(_sl.getValue(), 10);
		gt_assert_equal(_r.old, 5);
		gt_assert_equal(_r.new_, 10);
		_sl.setValue(-5);
		gt_assert_equal(_sl.getValue(), 0);
		_sl.setValue(0);
		gt_assert_equal(_r.n, 2);
	});

	_s.test("initial value outside the range is clamped", function() {
		var _sl = new UISlider("S", 0, 0, 200, noone, yellow_circle, 99, 0, 10);
		gt_assert_equal(_sl.getValue(), 10);
	});

	_s.test("changing min/max re-clamps the value", function() {
		var _sl = new UISlider("S", 0, 0, 200, noone, yellow_circle, 8, 0, 10);
		_sl.setMaxValue(5);
		gt_assert_equal(_sl.getValue(), 5);
		_sl.setMinValue(6);
		gt_assert_true(_sl.getMinValue() <= _sl.getMaxValue());
	});

	_s.test("vertical slider: inherit length getter/setter work", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 0, 0, 100, noone, yellow_circle, 0, 0, 10, UI_ORIENTATION.VERTICAL));
		gt_assert_no_throw(method({s: _sl}, function() { s.getInheritLength(); }));
		_sl.setInheritLength(true);
		gt_assert_true(_sl.getInheritLength());
		gt_assert_true(_sl.getInheritHeight());
	});

	_s.test("min == max does not produce NaN", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 20, 60, 200, noone, yellow_circle, 3, 3, 3));
		gt_assert_no_throw(function() { gt_render(); });
		gt_assert_equal(_sl.getValue(), 3);
	});

	_s.test("dragging the handle changes the value (integer steps)", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 20, 60, 200, noone, yellow_circle, 0, 0, 100));
		gt_render();
		var _d = _sl.getDimensions();
		var _m = gt_mouse();
		_m.moveTo(_d.x + 18, _d.y + 18);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(_d.x + 18 + 100, _d.y + 18);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_near(_sl.getValue(), 50, 1);
	});

	_s.test("float range: drag change can be set to a fractional step", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 20, 60, 200, noone, yellow_circle, 0, 0, 1));
		_sl.setDragChange(0.1);
		gt_render();
		var _d = _sl.getDimensions();
		var _m = gt_mouse();
		_m.moveTo(_d.x + 18, _d.y + 18);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(_d.x + 18 + 100, _d.y + 18);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_near(_sl.getValue(), 0.5, 0.06);
	});

	_s.test("a zero drag step means continuous and never hangs", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 20, 60, 200, noone, yellow_circle, 0, 0, 1));
		_sl.setDragChange(0);
		gt_render();
		var _d = _sl.getDimensions();
		var _m = gt_mouse();
		_m.moveTo(_d.x + 18, _d.y + 18);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(_d.x + 18 + 50, _d.y + 18);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_near(_sl.getValue(), 0.25, 0.02);
	});

	_s.test("wheel changes the value by the scroll step", function() {
		var _p = gt_host_panel();
		var _sl = _p.add(new UISlider("S", 20, 60, 200, noone, yellow_circle, 5, 0, 10));
		gt_render();
		gt_hover(_sl);
		gt_mouse().scrollDown();
		gt_frame();
		gt_assert_equal(_sl.getValue(), 6);
		gt_mouse().scrollUp();
		gt_frame();
		gt_assert_equal(_sl.getValue(), 5);
	});

	_s.test("renders horizontal and vertical", function() {
		var _p = gt_host_panel();
		_p.add(new UISlider("SH", 20, 60, 200, noone, yellow_circle, 5, 0, 10));
		_p.add(new UISlider("SV", 300, 60, 150, noone, yellow_circle, 5, 0, 10, UI_ORIENTATION.VERTICAL));
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s = gt_suite("ProgressBar");

	_s.test("value clamp, events and proportions", function() {
		var _pb = new UIProgressBar("PB", 0, 0, grey_button00, yellow_circle, 5, 0, 10);
		var _r = {n: 0};
		_pb.setCallback(UI_EVENT.VALUE_CHANGED, method(_r, function() { n++; }));
		_pb.setValue(100);
		gt_assert_equal(_pb.getValue(), 10);
		_pb.setValue(-1);
		gt_assert_equal(_pb.getValue(), 0);
		gt_assert_equal(_r.n, 2);
	});

	_s.test("min == max renders without NaN", function() {
		var _p = gt_host_panel();
		_p.add(new UIProgressBar("PB", 20, 60, grey_button00, yellow_circle, 0, 5, 5));
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s.test("vertical bar can be created without a progress sprite", function() {
		gt_assert_no_throw(function() { var _pb = new UIProgressBar("PBV", 0, 0, grey_button00, noone, 0, 0, 10, UI_ORIENTATION.VERTICAL); });
	});

	_s.test("all render behaviors, both orientations, with scale", function() {
		var _p = gt_host_panel();
		var _modes = [UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL, UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH, UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT];
		var _n = 0;
		for (var _o=0; _o<2; _o++) {
			for (var _i=0; _i<3; _i++) {
				var _pb = _p.add(new UIProgressBar("PB" + string(_n++), 20 + _n*10, 60, grey_button00, yellow_tick, 4, 0, 10, _o == 0 ? UI_ORIENTATION.HORIZONTAL : UI_ORIENTATION.VERTICAL));
				_pb.setRenderProgressBehavior(_modes[_i]);
				_pb.setSpriteRemainingProgress(yellow_cross);
			}
		}
		gt_assert_no_throw(function() { gt_render(); });
		ui_set_scale(2);
		gt_assert_no_throw(function() { gt_render(); });
	});

	_s.test("show value, prefix/suffix", function() {
		var _pb = new UIProgressBar("PB", 0, 0, grey_button00, yellow_circle, 5, 0, 10);
		_pb.setShowValue(true).setPrefix("HP: ").setSuffix("/10");
		gt_assert_true(_pb.getShowValue());
		gt_assert_equal(_pb.getPrefix(), "HP: ");
		gt_assert_equal(_pb.getSuffix(), "/10");
	});
}
