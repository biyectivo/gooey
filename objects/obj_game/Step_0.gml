if (live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(ord("2")))	obj_UI.setScale(obj_UI.getScale()+1);
if (keyboard_check_pressed(ord("1")))	obj_UI.setScale(max(obj_UI.getScale()-1, 1));

if (keyboard_check_pressed(vk_space)) {

	with (new UIPanel("Panel1", 20, 35, 400, 600, blue_panel)) {
		with (add(new UIButton("Button1", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Enabled Panel3", blue_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (obj_UI.exists("Panel3"))	obj_UI.get("Panel3").setEnabled(!obj_UI.get("Panel3").getEnabled());
			});
		}		
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
	}

	with (new UIPanel("Panel2", 454, 35, 300, 500, green_panel)) {
		with (add(new UIButton("Button2", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Visible Panel3", green_button00))) {
			setSpriteMouseover(green_button00);
			setSpriteClick(green_button01);
			setTextMouseover("[fnt_Test][fa_center][fa_middle][c_black]Visible Panel3");
			setTextClick("[fnt_Test][fa_center][fa_middle][c_lime]Visible Panel3");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (obj_UI.exists("Panel3"))	obj_UI.get("Panel3").setVisible(!obj_UI.get("Panel3").getVisible());
			});			
		}
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
	}
			
	with (new UIPanel("Panel3", 1371, 35, 480, 480, yellow_panel)) {
		setClipsContent(true);
		setTitle("[fa_top][fa_center][#000000][fnt_Test]OPTIONS");
		add(new UIButton("Button3", 25, 40, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 40, 80, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Have Fun", yellow_button00));
		with (add(new UIGroup("test", 60, 135, 200, 200, glassPanel))) {
			draggable = true;
			with (add(new UIButton("Button6", 20, 20, 100, 50, "[fnt_Test][fa_center][fa_middle][c_white]A",red_button00))) {
				setCallback(UI_EVENT.LEFT_CLICK, function() {
					show_debug_message("selected A");
				});
			}
			
			with (add(new UIButton("Button7", 20, 80, 100, 50, "[fnt_Test][fa_center][fa_middle][c_white]B",red_button00))) {
				setCallback(UI_EVENT.LEFT_CLICK, function() {
					show_debug_message("selected B");
				});
			}
		}
		setDragBarHeight(36);
		setCloseButton(new UIButton("close", getDimensions().width - sprite_get_width(yellow_boxCross), 0, sprite_get_width(yellow_boxCross), sprite_get_height(yellow_boxCross), "",yellow_boxCross));
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});
	}
	
	
	with (new UIPanel("Panel4", 778, 35, 100, 100, metalPanel)) {
		setCallback(UI_EVENT.RIGHT_CLICK, function() {
			show_debug_message("clicked");
		});	
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
	}
	
	with (new UIPanel("Panel5", 920, 35, 200, 200, red_panel)) {
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
	}

}


if (keyboard_check_pressed(ord("X"))) {
	if (obj_UI.exists("Panel3"))	obj_UI.get("Panel3").setClipsContent(!obj_UI.get("Panel3").getClipsContent())
}