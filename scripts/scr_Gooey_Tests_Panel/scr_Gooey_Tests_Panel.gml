/// @feather ignore all
/************************************************************************************
	gooey tests - UIPanel: title, tabs, close button, modal, drag and resize
*************************************************************************************/

function gt_register_panel() {
	var _s = gt_suite("Panel");

	_s.test("defaults", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		gt_assert_equal(_p.getType(), UI_TYPE.PANEL);
		gt_assert_equal(_p.getTabCount(), 1);
		gt_assert_equal(_p.getCurrentTab(), 0);
		gt_assert_true(_p.getDraggable());
		gt_assert_true(_p.getResizable());
		gt_assert_true(_p.getMovable());
		gt_assert_false(_p.getModal());
		gt_assert_true(_p.getClipsContent());
		gt_assert_false(_p.getTabControlVisible(), "tab header hidden with one tab");
	});

	_s.test("title set/get; title format is kept separate from the text", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.setTitle("Hello");
		gt_assert_equal(_p.getTitleWidget().getRawText(), "Hello");
		_p.setTitleFormat("[c_red]");
		gt_assert_equal(_p.getTitleFormat(), "[c_red]");
		gt_assert_equal(_p.getTitleWidget().getRawText(), "Hello");
	});

	_s.test("title offset and anchor accessors", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.setTitleAnchor(UI_RELATIVE_TO.TOP_LEFT);
		gt_assert_equal(_p.getTitleAnchor(), UI_RELATIVE_TO.TOP_LEFT);
		_p.setTitleOffset({x: 7, y: 9});
		var _o = _p.getTitleOffset();
		gt_assert_equal(_o.x, 7);
		gt_assert_equal(_o.y, 9);
	});

	_s.test("adding tabs", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		gt_assert_true(_p.addTab(2) == _p);
		gt_assert_equal(_p.getTabCount(), 3);
		gt_assert_true(_p.getTabControlVisible());
		gt_assert_equal(_p.getTabTitle(0), "Tab 1");
		gt_assert_equal(_p.getTabTitle(2), "Tab 3");
	});

	_s.test("tab text can be changed", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab();
		_p.setTabText(1, "Options");
		gt_assert_equal(_p.getTabTitle(1), "Options");
		gt_assert_equal(_p.getTabText(1), "Options");
		gt_assert_equal(_p.getTabTextMouseover(1), "Options");
		gt_assert_equal(_p.getTabTextSelected(1), "Options");
	});

	_s.test("gotoTab changes the current tab and the widgets that are children", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab();
		var _a = _p.add(new UIGroup("A", 0, 0, 10, 10, noone), 0);
		var _b = _p.add(new UIGroup("B", 0, 0, 10, 10, noone), 1);
		gt_assert_true(_p.getChildren()[0] == _a);
		_p.gotoTab(1);
		gt_assert_equal(_p.getCurrentTab(), 1);
		gt_assert_true(_p.getChildren()[0] == _b);
		gt_assert_true(_p.getChildren(0)[0] == _a);
	});

	_s.test("gotoTab with an out-of-range index is ignored", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab();
		gt_assert_no_throw(method({p: _p}, function() { p.gotoTab(9); p.gotoTab(-3); }));
		gt_assert_equal(_p.getCurrentTab(), 0);
	});

	_s.test("tab change fires VALUE_CHANGED on the tab control with (old, new)", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab();
		var _rec = {old: -1, new_: -1};
		_p.getTabControl().setCallback(UI_EVENT.VALUE_CHANGED, method(_rec, function(_o, _n) { old = _o; new_ = _n; }));
		_p.gotoTab(1);
		gt_assert_equal(_rec.old, 0);
		gt_assert_equal(_rec.new_, 1);
	});

	_s.test("nextTab / previousTab without wrap stop at the ends", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab(2);
		_p.nextTab();
		gt_assert_equal(_p.getCurrentTab(), 1);
		_p.nextTab().nextTab();
		gt_assert_equal(_p.getCurrentTab(), 2);
		_p.previousTab();
		gt_assert_equal(_p.getCurrentTab(), 1);
		_p.previousTab().previousTab();
		gt_assert_equal(_p.getCurrentTab(), 0);
	});

	_s.test("nextTab / previousTab with wrap loop around", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab(2);
		_p.previousTab(true);
		gt_assert_equal(_p.getCurrentTab(), 2);
		_p.nextTab(true);
		gt_assert_equal(_p.getCurrentTab(), 0);
	});

	_s.test("removeTab removes the tab, destroys its widgets and keeps >= 1 tab", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab(2);
		_p.add(new UIGroup("A", 0, 0, 10, 10, noone), 0);
		var _b = _p.add(new UIGroup("B", 0, 0, 10, 10, noone), 1);
		_b.add(new UIButton("BB", 0, 0, 10, 10, "x", blue_button00));
		_p.add(new UIGroup("C", 0, 0, 10, 10, noone), 2);
		_p.removeTab(1);
		gt_assert_equal(_p.getTabCount(), 2);
		gt_assert_false(ui_exists("B"), "widget on the removed tab must be destroyed");
		gt_assert_false(ui_exists("BB"), "and its descendants");
		gt_assert_true(ui_exists("C"));
		_p.removeTab(0);
		_p.removeTab(0);
		gt_assert_equal(_p.getTabCount(), 1, "the last tab cannot be removed");
	});

	_s.test("removeTab before the current tab keeps showing the same tab", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab(2);
		var _c = _p.add(new UIGroup("C", 0, 0, 10, 10, noone), 2);
		_p.gotoTab(2);
		_p.removeTab(0);
		gt_assert_equal(_p.getCurrentTab(), 1);
		gt_assert_true(_p.getChildren()[0] == _c);
	});

	_s.test("removing the current last tab moves to the new last tab", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab(1);
		_p.gotoTab(1);
		_p.removeTab(1);
		gt_assert_equal(_p.getCurrentTab(), 0);
		gt_assert_equal(_p.getTabCount(), 1);
	});

	_s.test("clicking a tab button switches tab", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setTabSprites(blue_button00);
		_p.setTabSpritesMouseover(blue_button00);
		_p.setTabSpritesSelected(grey_button00);
		_p.addTab();
		gt_render();
		var _btn = _p.getTabControl().getChildren(-1);
		_btn = _p.getTabControl().getChildren()[1];
		gt_click(_btn);
		gt_assert_equal(_p.getCurrentTab(), 1);
	});

	_s.test("common widgets stay visible across tabs", function() {
		var _p = new UIPanel("P", 10, 10, 300, 200, grey_panel);
		_p.addTab();
		var _c = _p.add(new UIGroup("Common", 0, 0, 10, 10, noone), -1);
		_p.gotoTab(1);
		gt_assert_true(array_contains(_p.getDescendants(), _c));
	});

	_s.test("tabs keep independent scroll offsets", function() {
		var _p = new UIPanel("P", 0, 0, 300, 200, grey_panel);
		_p.addTab();
		_p.scroll(UI_ORIENTATION.VERTICAL, 1, 30);
		_p.gotoTab(1);
		gt_assert_equal(_p.getScrollOffset(UI_ORIENTATION.VERTICAL), 0);
		_p.gotoTab(0);
		gt_assert_equal(_p.getScrollOffset(UI_ORIENTATION.VERTICAL), 30);
	});

	_s.test("close button: create, change and remove", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		gt_assert_equal(_p.getCloseButton(), noone);
		_p.setCloseButtonSprite(yellow_cross);
		var _btn = _p.getCloseButton();
		gt_assert_true(is_struct(_btn));
		gt_assert_equal(_btn.getSprite(), yellow_cross);
		_p.setCloseButtonSprite(yellow_checkmark);
		gt_assert_equal(_p.getCloseButton().getSprite(), yellow_checkmark);
		_p.setCloseButtonSprite(noone);
		gt_assert_equal(_p.getCloseButton(), noone);
	});

	_s.test("close button anchor getter (documented name) works", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setCloseButtonAnchor(UI_RELATIVE_TO.TOP_LEFT);
		gt_assert_equal(_p.getCloseButtonAnchor(), UI_RELATIVE_TO.TOP_LEFT);
	});

	_s.test("clicking the close button destroys the panel", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setCloseButtonSprite(yellow_cross);
		var _btn = _p.getCloseButton();
		gt_render();
		gt_click(_btn);
		gt_assert_false(ui_exists("P"));
		gt_assert_equal(array_length(ui_get_panels()), 0);
	});

	_s.test("modal: other panels are disabled until the modal is destroyed", function() {
		var _a = new UIPanel("A", 0, 0, 100, 100, grey_panel);
		var _b = new UIPanel("B", 0, 0, 100, 100, grey_panel);
		var _m = new UIPanel("M", 0, 0, 100, 100, grey_panel);
		_m.setModal(true);
		gt_assert_true(_m.getEnabled());
		gt_assert_false(_a.getEnabled());
		gt_assert_false(_b.getEnabled());
		gt_assert_true(ui_get_focused_panel() == _m);
		_m.destroy();
		gt_assert_true(_a.getEnabled());
		gt_assert_true(_b.getEnabled());
	});

	_s.test("switching the modal panel keeps every other panel disabled", function() {
		var _a = new UIPanel("A", 0, 0, 100, 100, grey_panel);
		var _b = new UIPanel("B", 0, 0, 100, 100, grey_panel);
		var _c = new UIPanel("C", 0, 0, 100, 100, grey_panel);
		_b.setModal(true);
		_c.setModal(true);
		gt_assert_false(_a.getEnabled(), "A");
		gt_assert_false(_b.getEnabled(), "B");
		gt_assert_true(_c.getEnabled(), "C");
		gt_assert_false(_b.getModal());
		gt_assert_true(_c.getModal());
	});

	_s.test("turning modal off re-enables the others", function() {
		var _a = new UIPanel("A", 0, 0, 100, 100, grey_panel);
		var _m = new UIPanel("M", 0, 0, 100, 100, grey_panel);
		_m.setModal(true).setModal(false);
		gt_assert_true(_a.getEnabled());
	});

	_s.test("modal overlay accessors", function() {
		var _p = new UIPanel("P", 0, 0, 100, 100, grey_panel);
		_p.setModalOverlayColor(c_red).setModalOverlayAlpha(0.3);
		gt_assert_equal(_p.getModalOverlayColor(), c_red);
		gt_assert_equal(_p.getModalOverlayAlpha(), 0.3);
	});

	_s.test("dragging the drag bar moves the panel", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setResizeBorderWidth(4);
		var _m = gt_mouse();
		_m.moveTo(250, 110);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(280, 130);
		gt_frame();
		gt_frame();
		_m.release();
		gt_frame();
		var _d = _p.getDimensions();
		gt_assert_equal(_d.x, 130);
		gt_assert_equal(_d.y, 120);
	});

	_s.test("a panel that is not movable does not move", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setMovable(false);
		var _m = gt_mouse();
		_m.moveTo(250, 110);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(280, 130);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_equal(_p.getDimensions().x, 100);
		gt_assert_equal(_p.getDimensions().y, 100);
	});

	_s.test("dragging the south-east corner resizes the panel", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setResizeBorderWidth(8);
		var _m = gt_mouse();
		_m.moveTo(398, 298);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(428, 328);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_equal(_p.getDimensions().width, 330);
		gt_assert_equal(_p.getDimensions().height, 230);
		gt_assert_equal(_p.getDimensions().x, 100);
	});

	_s.test("resizing from the west edge past the minimum width does not slide the panel", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setResizeBorderWidth(8).setMinWidth(250);
		var _m = gt_mouse();
		_m.moveTo(102, 200);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(300, 200);		// would shrink far below the minimum
		gt_frame(2);
		_m.release();
		gt_frame();
		var _d = _p.getDimensions();
		gt_assert_equal(_d.width, 250);
		gt_assert_equal(_d.x + _d.width, 400, "the east edge must stay put");
	});

	_s.test("a resizable=false panel cannot be resized", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.setResizable(false);
		var _m = gt_mouse();
		_m.moveTo(398, 298);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(428, 328);
		gt_frame(2);
		_m.release();
		gt_frame();
		gt_assert_equal(_p.getDimensions().width, 300);
	});

	_s.test("moving a panel survives a later relayout (offsets follow the move)", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		var _m = gt_mouse();
		_m.moveTo(250, 110);
		gt_frame();
		_m.press();
		gt_frame();
		_m.moveTo(280, 130);
		gt_frame(2);
		_m.release();
		gt_frame();
		_p.setDimensions(,, 320);
		gt_assert_equal(_p.getDimensions().x, 130, "panel snapped back to its original position");
	});

	_s.test("tab bar redimensioning does not rebuild tab buttons every frame", function() {
		var _p = new UIPanel("P", 100, 100, 300, 200, grey_panel);
		_p.addTab(2);
		var _btn = _p.getTabControl().getChildren()[0];
		var _count = {n: 0};
		var _orig = _btn.setSprite;
		gt_render();
		var _before = _btn.getDimensions().width;
		gt_render();
		gt_assert_equal(_btn.getDimensions().width, _before);
	});
}
