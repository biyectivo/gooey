if (live_call()) return live_result;
if (keyboard_check_pressed(vk_escape)) __game_restart();

if (!ui_exists("Test_Panel")) {
	var _fmt = "[fnt_Test]";
	
	var _panel = new UIPanel("Test_Panel", 0, 0, 450, 450, button_square_header_large_rectangle_screws, UI_RELATIVE_TO.MIDDLE_CENTER);
	_panel.setTitle($"{_fmt}[fa_top]gooey Demo").setCloseButtonSprite(red_cross).setCloseButtonOffset({x: -5, y:6});
	_panel.setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
		show_debug_message($"{current_time}");
	});
	var _button = new UIButton("Test_Button", 0, 0, 200, 100, $"{_fmt}[c_black]Hi world", button_rectangle_depth_gloss463, UI_RELATIVE_TO.MIDDLE_CENTER);
	_button.setSpriteMouseover(button_rectangle_depth_border461).setSpriteClick(button_rectangle_depth_border461);
	_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {
		show_debug_message(instance_number(UI));
	});
	_panel.add(_button);
}