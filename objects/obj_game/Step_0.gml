if (live_enabled && live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(ord("2")))	obj_UI.setScale(obj_UI.getScale()+1);
if (keyboard_check_pressed(ord("1")))	obj_UI.setScale(max(obj_UI.getScale()-1, 1));

if (keyboard_check_pressed(vk_space)) {
	with (new UIPanel("Panel1", 20, 20, 400, 600, blue_panel)) {
		with (add(new UIButton("Button1", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][col_white]Enabled Panel3", blue_button00))) {
			setCallback(UIEVENT.LEFT_CLICK, function() {
				if (obj_UI.exists("Panel3"))	obj_UI.get("Panel3").setEnabled(!obj_UI.get("Panel3").getEnabled());
			});
		}		
	}

	with (new UIPanel("Panel2", 200, 90, 300, 500, green_panel)) {
		with (add(new UIButton("Button2", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][col_white]Visible Panel3", green_button00))) {
			setCallback(UIEVENT.LEFT_CLICK, function() {
				if (obj_UI.exists("Panel3"))	obj_UI.get("Panel3").setVisible(!obj_UI.get("Panel3").getVisible());
			});
		}
	}
	
	with (new UIPanel("Panel3", 80, 400, 250, 300, yellow_panel)) {
		setTitle("[fa_center][fa_middle][#000000][fnt_Test]OPTIONS");
		add(new UIButton("Button3", 25, 40, 150, 50, "[fnt_Test][fa_center][fa_middle][col_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 80, 150, 50, "[fnt_Test][fa_center][fa_middle][col_white]Lines of Credit", yellow_button00));
		with (add(new UIGroup("test", 60, 135, 200, 200, glassPanel))) {
			draggable = true;
			add(new UIButton("Button6", 20, 20, 100, 50, "[fnt_Test][fa_center][fa_middle][col_white]Destroy",red_button00));
			add(new UIButton("Button7", 20, 80, 100, 50, "[fnt_Test][fa_center][fa_middle][col_white]Destroy",red_button00));
		}
		setDragBarHeight(36);
		setCloseButton(new UIButton("close", getDimensions().width - sprite_get_width(yellow_boxCross), 0, sprite_get_width(yellow_boxCross), sprite_get_height(yellow_boxCross), "",yellow_boxCross));
	}
	
	with (new UIPanel("Panel4", 800,200,100,100, metalPanel)) {
	}
	
	
}

