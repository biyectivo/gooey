if (live_call()) return live_result;
if (keyboard_check_pressed(vk_escape)) __game_restart();

if (!ui_exists("Test_Panel")) {
	var _fmt = "[fnt_Test]";
	
	var _panel = new UIPanel("Test_Panel", 0, 0, 450, 450, button_square_header_large_rectangle_screws, UI_RELATIVE_TO.MIDDLE_CENTER);
	
	_panel.setTitle($"{_fmt}[fa_top]gooey Demo").setCloseButtonSprite(red_cross).setCloseButtonOffset({x: -5, y:6});
	_panel.setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
		show_debug_message($"{current_time}");
	});
	_panel.setCallback(UI_EVENT.RIGHT_RELEASE, function()  {
		show_debug_message("Context menu");
	});
	
	var _grid = new UIGrid("Test_Grid", 2, 2);
	_grid.setShowGridOverlay(true);
	_panel.add(_grid);
	
	var _button = new UIButton("Test_Button", 0, 0, 200, 100, $"{_fmt}[c_black]Hi world", button_rectangle_depth_gloss463, UI_RELATIVE_TO.MIDDLE_CENTER);
	_button.setSpriteMouseover(button_rectangle_depth_border461).setSpriteClick(button_rectangle_depth_border461);
	_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_debug_message(instance_number(UI));
	});
	_grid.addToCell(_button, 0, 0);
	
	var _button = new UIButton("Test_Button2", 0, 0, 200, 100, $"{_fmt}[c_black]Enable/disable drill-through", button_rectangle_depth_gloss747, UI_RELATIVE_TO.MIDDLE_CENTER);
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
	
}