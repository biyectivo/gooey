if (live_enabled && live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(ord("2")))	obj_UI.setScale(obj_UI.getScale()+1);
if (keyboard_check_pressed(ord("1")))	obj_UI.setScale(max(obj_UI.getScale()-1, 1));

if (keyboard_check_pressed(vk_space)) {
	with (new UIPanel("Panel1", 20, 20, 400, 600, blue_panel)) {
		with (add(new UIButton("Button1", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][col_white]Enabled Panel3", blue_button00))) {
			setCallback(UIEVENT.LEFT_CLICK, function() {
				obj_UI.get("Panel3").setEnabled(!obj_UI.get("Panel3").getEnabled());
			});
		}		
	}

	with (new UIPanel("Panel2", 200, 90, 300, 500, green_panel)) {
		with (add(new UIButton("Button2", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][col_white]Visible Panel3", green_button00))) {
			setCallback(UIEVENT.LEFT_CLICK, function() {
				obj_UI.get("Panel3").setVisible(!obj_UI.get("Panel3").getVisible());
			});
		}
	}

	with (new UIPanel("Panel3", 80, 400, 250, 300, yellow_panel)) {
		add(new UIButton("Button3", 25, 15, 150, 50, "[fnt_Test][fa_center][fa_middle][col_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 75, 150, 50, "[fnt_Test][fa_center][fa_middle][col_white]Lines of Credit", yellow_button00));
		with (add(new UIPanel("test", 60, 135, 100, 100, red_panel))) {
			setDraggable(false);
			add(new UIButton("Button6", 0, 0, 100, 50, "[fnt_Test][fa_center][fa_middle][col_white]Destroy",red_button00));
		}	
	}
}
