if (live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(ord("2")))	UI.setScale(UI.getScale()+1);
if (keyboard_check_pressed(ord("1")))	UI.setScale(max(UI.getScale()-1, 1));



if (keyboard_check_pressed(vk_space)) {

	with (new UIPanel("Panel1", 20, 35, 400, 600, blue_panel)) {
		with (add(new UIButton("Button1", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Enabled Panel3", blue_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setEnabled(!UI.get("Panel3").getEnabled());
			});
		}		
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		with (add(new UICheckbox("test checkbox right", -10, 10, "[fnt_Test][fa_middle]Enable Panel3", checkbox_off, true, UI_RELATIVE_TO.TOP_RIGHT))) {
			setSpriteTrue(blue_boxCheckmark);
			setTextTrue("[fnt_Test][fa_middle]Disable Panel3");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setEnabled(!UI.get("Panel3").getEnabled());
			});
		}
	}

	with (new UIPanel("Panel2", 454, 35, 300, 500, green_panel)) {
		with (add(new UIButton("Button2", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Visible Panel3", green_button00))) {
			setSpriteMouseover(green_button01);
			setSpriteClick(green_button02);
			setTextMouseover("[fnt_Test][fa_center][fa_middle][c_black]Visible Panel3");
			setTextClick("[fnt_Test][fa_center][fa_middle][c_lime]Visible Panel3");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setVisible(!UI.get("Panel3").getVisible());
			});
			setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
				show_debug_message("Wheelie");
			});
		}
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		with (add(new UICheckbox("antialias", 25, 100, "[fnt_Test][fa_left][fa_middle][c_white]Enable antialias", checkbox_off))) {
			setTextTrue("[fnt_Test][fa_left][fa_middle][c_white]Disable antialias");
			setSpriteTrue(green_boxCheckmark);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("toggled")
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				show_debug_message("right click on checkbox")
			});
		}
		
		setCallback(UI_EVENT.RIGHT_CLICK, function() {
			if (UI.exists("antialias")) show_debug_message(UI.get("antialias").getValue());
		});	
	}
			
	with (new UIPanel("Panel3", 1371, 35, 480, 480, yellow_panel)) {
		setClipsContent(true);
		setTitle("[fa_top][fa_center][c_white][fnt_Test_Outline]OPTIONS");
		with (add(new UIText("", 25, 70, "[fa_left][fa_middle][c_gray]General options"))) {
			setTextMouseover("[fa_left][fa_middle][c_blue]General options").setTextClick("[fa_left][fa_middle][c_blue]General options!!!").setBackgroundColor(c_red).setBorderColor(c_black);
		}
		add(new UIButton("Button3", 25, 100, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 180, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Have Fun", yellow_button00));
		with (add(new UIGroup("test", 200, 100, 200, 200, glassPanel))) {
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
				setSpriteMouseover(yellow_button00);
				setSpriteClick(blue_button00);
				setTextMouseover("[fnt_Test][fa_center][fa_middle][c_red]B");
				setTextClick("[fnt_Test][fa_center][fa_middle][c_lime]B");
			}
		}
		setDragBarHeight(36);
				
		setCloseButtonSprite(yellow_boxCross);
		
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
		
		add(new UIText("test", -10, -10, "[fnt_Test][fa_left][fa_middle][c_black]this is a [c_red]test", UI_RELATIVE_TO.BOTTOM_RIGHT));
	}
	
	with (new UIPanel("Panel5", 920, 35, 200, 200, red_panel)) {
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
	}

	var _id = new UIPanel("Panel6", 920, 300, 200, 100, blue_panel);
	_id.setDragBarHeight(10).setTitle("[fa_right][fa_top][fnt_Test][rainbow]Chaining Test").setTitleAnchor(UI_RELATIVE_TO.TOP_RIGHT);

}

if (keyboard_check_pressed(ord("X"))) {
	if (UI.exists("Panel3"))	UI.get("Panel3").setClipsContent(!UI.get("Panel3").getClipsContent())
}

//UI.get("Panel3").setCloseButtonSprite(noone);