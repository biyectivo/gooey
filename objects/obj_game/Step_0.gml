if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(vk_f2))	UI.setScale(UI.getScale()+1);
if (keyboard_check_pressed(vk_f1))	UI.setScale(max(UI.getScale()-1, 1));



if (!self.widgets_created && keyboard_check_pressed(vk_space)) {
	self.widgets_created = true;
	
	
	
	with (new UIPanel("Panel1", 20, 35, 400, 600, blue_panel)) {
		// First tab
		with (add(new UIButton("Button1", 25, 50, 200, 50, "[c_white]Enabled Panel3", blue_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setEnabled(!UI.get("Panel3").getEnabled());
			});
		}
		addTab();
		// Second tab
		with (add(new UIButton("Button1 Second Tab", 25, 50, 200, 50, "[c_white]Alert", blue_button00), 1)) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_message("Sup");
			});
		}
		addTab();
		// Third tab
		with (add(new UIButton("Button1 third Tab", 25, 50, 200, 50, "[c_white]center me", yellow_button00, UI_RELATIVE_TO.MIDDLE_CENTER), 2)) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				window_center();
			});
		}
		
		var _parent_w = self.getDimensions().width;
		var _parent_h = self.getDimensions().height;
		var _parent_start = self.getDragBarHeight();
		//with (add(new UIGroup("group", 0, 0, _parent_w, 20, blue_button11, UI_RELATIVE_TO.BOTTOM_CENTER),-1)) {
		
		/*
		with (add(new UIGroup("group", 0, _parent_start, _parent_w, 20, blue_button11, UI_RELATIVE_TO.TOP_LEFT),-1)) {
			var _n = UI.get("Panel1").getTabCount();
			//var _w = UI.get("Panel1").getDimensions().width / _n;
			//var _w = getParent().getDimensions().width / _n;
			var _w = 100;
			for (var _i=0; _i<_n; _i++) {
				with (add(new UIButton("a"+string(_i), 0 + _i*_w, 0, _w, 20, "[c_orange]tab "+string(_i), blue_button03))) {
					self.setUserData("tab_index", _i);
					self.setCallback(UI_EVENT.LEFT_CLICK, function() {
						if (UI.exists("Panel1"))	UI.get("Panel1").gotoTab(self.getUserData("tab_index"));
					});
				}
				
			}
			self.setInheritWidth(true);
		}
		*/
		/*
		with (add(new UIGroup("group", 0, 0, 100, _parent_h, green_button11, UI_RELATIVE_TO.TOP_RIGHT),-1)) {
			var _n = UI.get("Panel1").getTabCount();
			var _h = 50;
			for (var _i=0; _i<_n; _i++) {
				with (add(new UIButton("a"+string(_i), 0, 0 + _i*_h, 100, _h, "[c_orange]"+self.getParent().getTabTitle(_i), red_button03))) {
					self.setUserData("tab_index", _i);
					self.setCallback(UI_EVENT.LEFT_CLICK, function() {
						if (UI.exists("Panel1"))	UI.get("Panel1").gotoTab(self.getUserData("tab_index"));
					});
				}
				
			}
			self.setInheritHeight(true);
		}
		*/
		add(new UIText("gaa", 0, -30, "[jitter][#152499]This text should appear regardless of tab[/jitter]", UI_RELATIVE_TO.BOTTOM_CENTER), -1);
		
		
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		with (add(new UICheckbox("test checkbox right", 0, 150, "[fa_left]Antialias checkbox (off)", checkbox_off, true, UI_RELATIVE_TO.TOP_CENTER))) {
			setSpriteTrue(blue_boxCheckmark);
			setTextTrue("[fa_left]Antialias checkbox (on)");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").setEnabled(!UI.get("antialias").getEnabled());
			});
		}
		with (add(new UICheckbox("test checkbox right2", 0, 250, "[fa_left]Antialias visible", checkbox_off, true, UI_RELATIVE_TO.TOP_CENTER))) {
			setSpriteTrue(yellow_boxCross);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").setVisible(!UI.get("antialias").getVisible());
			});
		}
		setCloseButtonSprite(blue_boxCross);
		
		setImageAlpha(0.4);
		
		setTabControlVisible(true);
		setSpriteTabBackground(red_panel);
		setTabControlAlignment(UI_RELATIVE_TO.TOP_LEFT);
	}
	
	

	with (new UIPanel("Panel2", 454, 35, 300, 500, green_panel)) {
		with (add(new UIButton("Button2", 25, 15, 200, 50, "[c_white]Visible Panel3", green_button00))) {
			setSpriteMouseover(green_button01);
			setSpriteClick(green_button02);
			setTextMouseover("[c_black]Visible Panel3");
			setTextClick("[c_lime]Visible Panel3");
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("Panel3"))	UI.get("Panel3").setVisible(!UI.get("Panel3").getVisible());
			});
			setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
				show_debug_message("Wheelie");
			});
			setInheritWidth(true);
		}
		setCallback(UI_EVENT.RIGHT_RELEASE, function() {
			show_debug_message(self.__ID+": "+string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		with (add(new UICheckbox("antialias", 25, 100, "[fa_left][c_white]Enable antialias", checkbox_off))) {
			setTextTrue("[fa_left][c_white]Disable antialias");
			setSpriteTrue(green_boxCheckmark);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("toggled")
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				show_debug_message("right click on checkbox")
				show_debug_message(self.__ID+": "+string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
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
		}
		
		with (add(new UITextBox("textbox2", 25, 300, 200, 100, grey_panel, 0))) {
			setPlaceholderText("Something else...");
			setTextFormat("[fa_left][fa_top][c_blue]");			
		}
		
		add(new UIText("txtuser", 25, 280, "USERNAME"));
		
		with (add(new UIButton("textbox1_mask", 25, 400, 100, 20, "[c_white]Mask/unmask", red_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaskText(!UI.get("textbox1").getMaskText());
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				if (UI.exists("antialias"))	UI.get("antialias").toggle();
			});
		}
		
		
		with (add(new UIButton("textbox1_maxchar", 25, 450, 100, 20, "[c_white]Max chars 10/0", red_button00))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(10);
			});
			setCallback(UI_EVENT.RIGHT_CLICK, function() {
				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(0);
			});
		}
		
		with (add(new UICheckbox("slider checkbox", 25, 500, "textbox2 read only", grey_box, false))) {
			setSpriteTrue(red_boxCheckmark);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				if (UI.exists("textbox2"))	UI.get("textbox2").setReadOnly(!UI.get("textbox2").getReadOnly());
			});
		}
		
		
		setCloseButtonSprite(green_boxCross);
	}
			
	with (new UIPanel("Panel3", 1371, 35, 480, 480, yellow_panel)) {
		setClipsContent(true);
		setTitle("[fa_top][c_white][fnt_Test_Outline]OPTIONS");
		with (add(new UIText("OptText", 25, 70, "[fa_left][c_gray]General options"))) {
			setTextMouseover("[fa_left][c_blue]General options").setTextClick("[fa_left][c_blue]General options!!!").setBackgroundColor(c_red).setBorderColor(c_black);
		}
		add(new UIButton("Button3", 25, 100, 150, 50, "[c_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 180, 150, 50, "[c_white]Have Fun", yellow_button00));
		with (add(new UIGroup("testGroup", 200, 100, 200, 200, glassPanel))) {
			draggable = true;
			with (add(new UIButton("Button6", 20, 20, 100, 50, "[c_white]A",red_button00))) {
				setCallback(UI_EVENT.LEFT_CLICK, function() {
					show_debug_message("selected A " + self.__ID);
				});
			}
			
			with (add(new UIButton("Button7", 20, 80, 100, 50, "[c_white]B",red_button00))) {
				setCallback(UI_EVENT.LEFT_CLICK, function() {
					show_debug_message("selected B");
				});
				setSpriteMouseover(yellow_button00);
				setSpriteClick(blue_button00);
				setTextMouseover("[c_red]B");
				setTextClick("[c_lime]B");
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
		
		add(new UIText("test", -10, -10, "[fa_left][c_black]this is a [c_red]test", UI_RELATIVE_TO.BOTTOM_RIGHT));
		
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
			setTextFormat("[c_black]");
			setCallback(UI_EVENT.VALUE_CHANGED, function() {
				show_debug_message("Slider changed");
			});
		}
		
		with (add(new UICheckbox("slider checkbox", 50, 350, "[fa_left]Horizontal slider", grey_box, true))) {
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
	_id.setTitle("[fa_right][fa_top][rainbow]Chaining Test       ").setTitleAnchor(UI_RELATIVE_TO.TOP_RIGHT).setCloseButtonSprite(blue_boxCross);
	_id.addTab();	
	var _fmt = "[fa_left][c_white]";
	var _selfmt = "[fa_left][c_red]";
	with (_id.add(new UIOptionGroup("testgroup", 32, 50, [_fmt+"The option", _fmt+"Really freaking big option", _fmt+"Mini", _fmt+"The big blue boot"], grey_circle))) {
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
				if (UI.exists("Panel6_TabControl_Group_TabButton0")) {
					show_debug_message(string(UI.get("Panel6_TabControl_Group_TabButton0").getVisible())+" "+string(UI.get("Panel6_TabControl_Group_TabButton0").getEnabled()));
					show_debug_message(string(UI.get("Panel6_TabControl_Group_TabButton1").getVisible())+" "+string(UI.get("Panel6_TabControl_Group_TabButton1").getEnabled()));
				}
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
if (keyboard_check_pressed(ord("I")) && UI.exists("Panel1"))	UI.get("Panel1").addTab(); 
if (keyboard_check_pressed(ord("P")) && UI.exists("Panel1"))	UI.get("Panel1").nextTab(true); 
if (keyboard_check_pressed(ord("O")) && UI.exists("Panel1"))	UI.get("Panel1").previousTab(true); 
if (keyboard_check_pressed(ord("L")) && UI.exists("Panel1"))	UI.get("Panel1").removeTab(); 
if (keyboard_check_pressed(ord("D")) && UI.exists("textbox2"))	UI.get("textbox2").destroy(); 
	
if (keyboard_check_pressed(ord("V")) && UI.exists("Button7"))	show_message(UI.get("Button7").getContainingPanel().__ID); 
if (keyboard_check_pressed(ord("B")) && UI.exists("Button1 Second Tab"))	show_message(UI.get("Button1 Second Tab").getContainingTab()); 
if (keyboard_check_pressed(ord("N")) && UI.exists("gaa"))	show_message(UI.get("gaa").getContainingTab()); 
if (keyboard_check_pressed(ord("F")) && UI.exists("Panel1"))	UI.get("Panel1").setVerticalTabs(!UI.get("Panel1").getVerticalTabs());
if (keyboard_check_pressed(ord("G")) && UI.exists("Panel1"))	UI.get("Panel1").setTabControlAlignment(UI_RELATIVE_TO.BOTTOM_RIGHT);
if (keyboard_check_pressed(vk_f1) && UI.exists("Panel6"))		UI.get("Panel6").setTabControlVisible(!UI.get("Panel6").getTabControlVisible());

if (keyboard_check_pressed(vk_backspace)) UI.get("Toolbar").destroy();