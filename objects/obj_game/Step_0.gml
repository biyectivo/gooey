//if (live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(vk_f2))	UI.setScale(UI.getScale()+1);
if (keyboard_check_pressed(vk_f1))	UI.setScale(max(UI.getScale()-1, 1));



if (!self.widgets_created && keyboard_check_pressed(vk_space)) {
	self.widgets_created = true;
	
	
	
	with (new UIPanel("Panel1", 20, 35, 400, 600, blue_panel)) {
		// First tab
		with (add(new UIButton("Button1", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Enabled Panel3", blue_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setEnabled(!UI.get("Panel3").getEnabled());
			});
		}
		addTab();
		// Second tab
		with (add(new UIButton("Button1 Second Tab", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]Alert", blue_button00), 1)) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_message("Sup");
			});
		}
		addTab();
		// Third tab
		with (add(new UIButton("Button1 third Tab", 25, 15, 200, 50, "[fnt_Test][fa_center][fa_middle][c_white]center me", yellow_button00, UI_RELATIVE_TO.MIDDLE_CENTER), 2)) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				window_center();
			});
		}
		
		add(new UIText("gaa", 0, 0, "[fnt_Test][jitter][#152499]This text should appear regardless of tab[/jitter]", UI_RELATIVE_TO.BOTTOM_CENTER), -1);
		
		
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		with (add(new UICheckbox("test checkbox right", 0, 150, "[fnt_Test][fa_middle]Antialias checkbox", checkbox_off, true, UI_RELATIVE_TO.TOP_CENTER))) {
			setSpriteTrue(blue_boxCheckmark);
			setTextTrue("[fnt_Test][fa_middle]Antialias checkbox");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").setEnabled(!UI.get("antialias").getEnabled());
			});
		}
		with (add(new UICheckbox("test checkbox right2", 0, 250, "[fnt_Test][fa_middle]Antialias visible", checkbox_off, true, UI_RELATIVE_TO.TOP_CENTER))) {
			setSpriteTrue(yellow_boxCross);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").setVisible(!UI.get("antialias").getVisible());
			});
		}
		setCloseButtonSprite(blue_boxCross);
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
			setEnabled(true);
			setCallback(UI_EVENT.VALUE_CHANGED, function() {
				show_debug_message("Antialias checkbox changed");
			});
		}
		
		setCallback(UI_EVENT.RIGHT_CLICK, function() {
			if (UI.exists("antialias")) show_debug_message(UI.get("antialias").getValue());
		});	
		
		with (add(new UITextBox("textbox1", 25, 200, 200, 100, grey_panel, 0))) {
			setPlaceholderText("Type something...");
			setTextFormat("[fa_left][fa_top][c_black][fnt_Test3]");
			setAllowUppercaseLetters(false);
			setAllowSpaces(false);
			setAllowSymbols(true);
			setSymbolsAllowed(".,-");
			setCallback(UI_EVENT.VALUE_CHANGED, function() {				
				show_debug_message("t1 ["+getText()+"]  keyboard string: ("+keyboard_string+")");
			});
		}
		
		with (add(new UITextBox("textbox2", 25, 300, 200, 100, grey_panel, 0))) {
			setPlaceholderText("Something else...");
			setTextFormat("[fa_left][fa_top][c_blue][fnt_Test]");
			setCallback(UI_EVENT.VALUE_CHANGED, function() {
				show_debug_message("t2 ["+getText()+"]  keyboard string: ("+keyboard_string+")");
			});
		}
		
		add(new UIText("txtuser", 25, 280, "USERNAME"));
		
		with (add(new UIButton("textbox1_mask", 25, 400, 100, 20, "[fnt_Test][fa_center][fa_middle][c_white]Mask/unmask", red_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaskText(!UI.get("textbox1").getMaskText());
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").toggle();
			});
		}
		
		
		with (add(new UIButton("textbox1_maxchar", 25, 450, 100, 20, "[fnt_Test][fa_center][fa_middle][c_white]Max chars 10/0", red_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(10);
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(0);
			});
		}
		
		with (add(new UICheckbox("slider checkbox", 25, 500, "[fnt_Test][fa_middle]textbox2 read only", grey_box, false))) {
			setSpriteTrue(red_boxCheckmark);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox2"))	UI.get("textbox2").setReadOnly(!UI.get("textbox2").getReadOnly());
			});
		}
		
		
		setCloseButtonSprite(green_boxCross);
	}
			
	with (new UIPanel("Panel3", 1371, 35, 480, 480, yellow_panel)) {
		setClipsContent(true);
		setTitle("[fa_top][fa_center][c_white][fnt_Test_Outline]OPTIONS");
		with (add(new UIText("OptText", 25, 70, "[fa_left][fa_middle][c_gray]General options"))) {
			setTextMouseover("[fa_left][fa_middle][c_blue]General options").setTextClick("[fa_left][fa_middle][c_blue]General options!!!").setBackgroundColor(c_red).setBorderColor(c_black);
		}
		add(new UIButton("Button3", 25, 100, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 180, 150, 50, "[fnt_Test][fa_center][fa_middle][c_white]Have Fun", yellow_button00));
		with (add(new UIGroup("testGroup", 200, 100, 200, 200, glassPanel))) {
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
		
		setCloseButtonSprite(grey_boxCross);
	}
	
	with (new UIPanel("Panel5", 920, 35, 350, 400, red_panel)) {
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		
		with (add(new UISlider("slider1", 50, 100, 150, grey_sliderHorizontal, grey_sliderDown, 10, 5, 50, UI_ORIENTATION.HORIZONTAL))) {
			setSmallChange(0.5);
			setBigChange(1);
			setScrollChange(2);
			setShowMinMaxText(true);
			setShowHandleText(true);
			setTextFormat("[fa_middle][fa_center][c_black]");
			setCallback(UI_EVENT.VALUE_CHANGED, function() {
				show_debug_message("Slider changed");
			});
		}
		
		with (add(new UICheckbox("slider checkbox", 50, 350, "[fnt_Test][fa_middle]Horizontal slider", grey_box, true))) {
			setSpriteTrue(red_boxCheckmark);			
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("slider1")) {
					with (UI.get("slider1")) {						
						if (getOrientation() == UI_ORIENTATION.HORIZONTAL) {
							setSpriteBase(grey_sliderVertical);
							setSpriteHandle(grey_sliderRight);
							setOrientation(UI_ORIENTATION.VERTICAL);
						}
						else {
							setSpriteBase(grey_sliderHorizontal);
							setSpriteHandle(grey_sliderDown);
							setOrientation(UI_ORIENTATION.HORIZONTAL);
						}
					}
				}
			});
		}
		
		setCloseButtonSprite(red_boxCross);
	}

	var _id = new UIPanel("Panel6", 920, 550, 600, 200, blue_panel);
	_id.setDragBarHeight(10).setTitle("[fa_right][fa_top][fnt_Test][rainbow]Chaining Test       ").setTitleAnchor(UI_RELATIVE_TO.TOP_RIGHT).setCloseButtonSprite(blue_boxCross);
	var _fmt = "[fa_middle][fa_left][c_white][fnt_Test]";
	var _selfmt = "[fa_middle][fa_left][c_red][fnt_Test]";
	with (_id.add(new UIOptionGroup("testgroup", 20, 50, [_fmt+"The option", _fmt+"Really freaking big option", _fmt+"Mini", _fmt+"The big blue boot"], grey_circle))) {
		setOptionArraySelected([_selfmt+"The option", _selfmt+"Really freaking big option", _selfmt+"Mini", _selfmt + "The big blue boot"]);
		setSpriteSelected(grey_boxTick);
		setSpacing(15);
		setCallback(UI_EVENT.VALUE_CHANGED, function() {
			show_debug_message(self.__ID+" I changed. The Option")
		});
	}
	
	with (new UIPanel("Toolbar", 0, 0, 300, 80, glassPanel, UI_RELATIVE_TO.BOTTOM_CENTER)) {
		setDraggable(false);
		setResizable(false);
		with(add(new UIButton("Option1", -100, 0, 50, 50, "O1", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("Toggling group orientation");
				if (UI.exists("testgroup"))	UI.get("testgroup").setVertical(!UI.get("testgroup").getVertical());
			});
		}
		with(add(new UIButton("Option2", -35, 0, 50, 50, "O2", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox2"))	show_debug_message(UI.get("textbox1").getDimensions().height);
				if (UI.exists("testgroup")) show_debug_message( string(UI.get("testgroup").getIndex())+" "+UI.get("testgroup").getOptionRawText() );
			});
		}
		with(add(new UIButton("Option3", 35, 0, 50, 50, "O3", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				//show_debug_message("Selected toolbar 3");
				show_debug_message(keyboard_string);
			});
		}
		with(add(new UIButton("Option4", 100, 0, 50, 50, "O4", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("Selected toolbar 4");
				if (UI.exists("textbox1"))	show_debug_message(UI.get("textbox1").getText());
				if (UI.exists("textbox2"))	show_debug_message(UI.get("textbox2").getText());								
			});
		}
		
	}
	
	

}



if (keyboard_check_pressed(ord("X"))) {
	if (UI.exists("Panel3"))	UI.get("Panel3").setClipsContent(!UI.get("Panel3").getClipsContent())
}

if (keyboard_check_pressed(ord("Z"))) {
	if (UI.exists("Panel3"))	{
		var _p = UI.get("Panel3").getChildren();
		for (var _i=0, _n=array_length(_p); _i<_n; _i++) show_debug_message(_p[_i].__ID);
	}
}

//UI.get("Panel3").setCloseButtonSprite(noone);


//if (UI.exists("Toolbar"))	UI.get("Toolbar").destroy();

// Tabs
	if (keyboard_check_pressed(ord("P")) && UI.exists("Panel1"))	UI.get("Panel1").nextTab(true); 
	if (keyboard_check_pressed(ord("O")) && UI.exists("Panel1"))	UI.get("Panel1").previousTab(true); 
	if (keyboard_check_pressed(ord("L")) && UI.exists("Panel1"))	UI.get("Panel1").removeTab(); 