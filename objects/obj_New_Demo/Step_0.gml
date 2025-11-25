live_auto_call;

if (keyboard_check_pressed(vk_escape)) __game_restart();
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("F"))) {
	window_set_fullscreen(!window_get_fullscreen());
	//if (keyboard_check(vk_shift)) display_set_gui_maximize();
}


if (keyboard_check_pressed(ord("P"))) {
	show_debug_message($"Fullscreen: {window_get_fullscreen()} {window_get_borderless_fullscreen()}");
	show_debug_message($"App: {surface_get_width(application_surface)}x{surface_get_height(application_surface)}");
	show_debug_message($"Window: {window_get_width()}x{window_get_height()}");
	show_debug_message($"GUI: {display_get_gui_width()}x{display_get_gui_height()}");
	show_debug_message($"Display: {display_get_width()}x{display_get_height()}");
	show_debug_message($"Camera: {camera_get_active()} {camera_get_view_width(camera_get_active())}x{camera_get_view_height(camera_get_active())}");
	show_debug_message($"DPI: {display_get_dpi_x()}x{display_get_dpi_y()}");
	show_debug_message($"Device/type/version: {os_device} {os_type} {os_version}");
	show_debug_message($"Is browser: {os_browser != browser_not_a_browser}");
	show_debug_message($"Browser: {browser_width}x{browser_height}");
}


if (!ui_exists("Test1")) {
	var _fmt = "[fnt_Test][c_black]";
	var _fmt2 = "[fnt_Test][c_black][fa_left]";
	
	var _panel = new UIPanel("Test1", 50, 50, 400, 300, grey_panel);
	_panel.setTitle(_fmt+"TEST");
	_panel.setClipsContent(false);
	
	var _grid = new UIGrid("Grid1", 2, 2);
	_grid.setCellsClipContents(false);
	//_grid.setMargins(50);
	_panel.add(_grid);
	
	//var _button = new UIButton("Button1", 0, 0, 0, 0, _fmt+"Hi", blue_button00, UI_RELATIVE_TO.MIDDLE_CENTER);
	//_button.setInheritWidth(true).setInheritHeight(true)
	//_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {
	//	show_debug_message("TEST Button1");
	//});
	//_grid.addToCell(_button, 1, 1);
	_grid.setShowGridOverlay(true);
	
	var _txt = new UIText("Text1", 50, 50, _fmt2+"This is the rhythm of the night");
	_txt.setMaxWidth(50);
	_txt.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_debug_message("TEST")
	});
	_grid.addToCell(_txt, 0, 0);
	//var _grp = new UIGroup("Group1", 30, 30, 370, 270, blue_panel);
	//_grp.setImageAlpha(0.2);
	//_grp.setClipsContent(true);
	
	//_grp.add(_txt);
	//_panel.add(_grp);
	
	
	//var _drp = new UIDropdown("TestDrp", 0, -100, ["Test1", "Test2", "Testes"], grey_button00, grey_button00, 0, UI_RELATIVE_TO.BOTTOM_CENTER);
	var _drp = new UIDropdown("TestDrp", 300, 100, ["Test1", "Test2", "Testes"], grey_button00, grey_button00, 0);
	_drp.setSpriteArrow(icon_arrow_down_dark)
	_drp.setTextFormatSelected(_fmt).setTextFormatUnselected(_fmt).setTextFormatMouseover(_fmt)
	//_grid.addToCell(_drp, 0, 1);	
	_grid.addToCell(_drp, 1, 1);	
	
	var _btn = new UIButton("TestBtn", 300, 50, 100, 20, "ABC", green_button00);
	_btn.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_debug_message("TESTS");
	});
	_panel.add(_btn);
}

if (!ui_exists("Test_Panel")) {
	var _fmt = "[fnt_Test]";
	
	var _panel = new UIPanel("Test_Panel", 0, 0, 500, 450, button_square_header_large_rectangle_screws, UI_RELATIVE_TO.MIDDLE_CENTER);
	_panel.setOnDestroyCallback(function() {
		show_debug_message("RIP Panel");
	});
	
	_panel.setTitle($"{_fmt}[fa_top]gooey Demo").setCloseButtonSprite(red_cross).setCloseButtonOffset({x: -5, y:6});
	_panel.setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
		show_debug_message($"{current_time}");
	});
	_panel.setCallback(UI_EVENT.RIGHT_RELEASE, function()  {
		show_debug_message("Context menu");
	});
	
	var _grid = new UIGrid("Test_Grid", 2, 2);
	_grid.setShowGridOverlay(true).setMargins(20).setMarginTop(80).setSpacings(20);
	_grid.setCellsClipContents(true);
	_panel.add(_grid);
	
	
	
	var _button = new UIButton("Test_Button", 0, 0, 200, 100, $"{_fmt}[c_black]Hi world", button_rectangle_depth_gloss463, UI_RELATIVE_TO.MIDDLE_CENTER);
	//_panel.add(_button);
	//_button.setSprite(button_rectangle_depth_border461, true);
	_button.setSpriteMouseover(button_rectangle_depth_border461).setSpriteClick(button_rectangle_depth_border461);
	_button.setCallback(UI_EVENT.MOUSE_ENTER, function() {
		var _panel = new UIPanel("Test_Panel2", -30, 30, 200, 200, red_panel, UI_RELATIVE_TO.TOP_RIGHT);
	});
	_button.setCallback(UI_EVENT.MOUSE_EXIT, function() {
		if (ui_exists("Test_Panel2"))	ui_get("Test_Panel2").destroy();
	});
	_grid.addToCell(_button, 0, 0);
	
	var _button = new UIButton("Test_Button2", 0, 0, 200, 100, $"{_fmt}[c_black]Enable/disable\ndrill-through", button_rectangle_depth_gloss747, UI_RELATIVE_TO.MIDDLE_CENTER);
	_button.setSpriteMouseover(button_rectangle_depth_border745).setSpriteClick(button_rectangle_depth_border745);
	_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		//ui_get("Test_Button").__drill_through_mouse_wheel_down = (!ui_get("Test_Button").__drill_through_mouse_wheel_down);
		ui_get("Test_Button").setDrillThroughMouseWheelDown(!ui_get("Test_Button").getDrillThroughMouseWheelDown());
	});
	_button.setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
		show_debug_message("NOPE");
	});
	//_panel.add(_button);
	
	
	_grid.addToCell(_button, 0, 1);
	_panel.setCallback(UI_EVENT.LEFT_HOLD, function() {
		show_debug_message("left")
	})
	_panel.setCallback(UI_EVENT.RIGHT_RELEASE, function() {
		show_debug_message("right")
	})
	var _button = new UIButton("Test_Button3", 0, 0, 200, 100, $"[c_black]Hi world", button_rectangle_depth_gloss463, UI_RELATIVE_TO.MIDDLE_CENTER);
	_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_message(ui_get("TestTextbox").getText());
	});
	_button.setCallback(UI_EVENT.RIGHT_RELEASE, function() {
		show_debug_message("right button")
	});
	_grid.addToCell(_button, 1,0);
	
	
	var _txt = new UITextBox("TestTextbox", 0, 0, 200, 80, grey_button02,, UI_RELATIVE_TO.MIDDLE_CENTER);
	_txt.setTextFormat("[c_black]")
	_txt.setAdjustHeight(true);
	_grid.addToCell(_txt, 1, 1);
	
	var _panel = new UIPanel("Test_Panel", 0, 0, 500, 450, button_square_depth_line, UI_RELATIVE_TO.MIDDLE_CENTER);
	var _spr = sprite_scale(blue_button12, 0, 6,3,true);
	//var _btn = new UIButton("Test_Button", 40, 40, sprite_get_width(Sprite972), sprite_get_height(Sprite972), "Hola", Sprite972);
	var _btn = new UIButton("Test_Button", 40, 40, sprite_get_width(_spr), sprite_get_height(_spr), "Hola", _spr);
	//_panel.setClipsContent(false);
	_panel.add(_btn);
}

if (!ui_exists("Test2Panel")) {
	var _panel = new UIPanel("Test2Panel", 500, 400, 200, 100, green_panel);
	var _txt = new UIText("TestText", 40, 40, "[fa_left]Probando, 1,2,3...");
	_panel.add(_txt);
	_txt.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_debug_message("YAY")
	});
	
}


if (!ui_exists("Test3Panel")) {
	var _panel = new UIPanel("Test3Panel", 500, 400, 400, 400, yellow_panel);
	var _grid = new UIGrid("Test3Grid", 5, 3);
	_grid.setShowGridOverlay(true);
	_panel.add(_grid);
	for (var _i=0; _i<30; _i++) {
		var _txt = new UIText(string($"Test3Text{_i}"), _i, 0, string($"{_i}"), UI_RELATIVE_TO.MIDDLE_CENTER);
		_grid.addNext(_txt);
	}
}