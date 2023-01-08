if (live_call()) return live_result;

if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(vk_f2))	UI.setScale(UI.getScale()+1);
if (keyboard_check_pressed(vk_f1))	UI.setScale(max(UI.getScale()-1, 1));

if (!self.widgets_created && keyboard_check_pressed(vk_space)) {
	self.widgets_created = true;
	
	//with (new UIPanel("aaa", 0, -100, 256, 64, transparent, UI_RELATIVE_TO.BOTTOM_LEFT)) {
	with (new UIPanel("aaa", 0, 0, 300, 300, transparent, UI_RELATIVE_TO.BOTTOM_LEFT)) {		
		setMovable(false);
		setResizable(false);		
		with (add(new UIProgressBar("progress", 0, 0, base4, progress3, 10, 0, 100))) {
			setSpriteProgressAnchor({x: 0, y: sprite_get_height(base4)});
			setOrientation(UI_ORIENTATION.VERTICAL);
			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL);
			setProgressRepeatUnit(20);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message(self.getValue());
			});
		}
		with (add(new UIProgressBar("progress2", 20, 0, base4, progress4, 10, 0, 100))) {
			setSpriteProgressAnchor({x: 0, y: sprite_get_height(base4)});
			setOrientation(UI_ORIENTATION.VERTICAL);
			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH);
			setProgressRepeatUnit(20);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message(self.getValue());
			});
			setShowValue(true).setPrefix("$").setSuffix(" mln").setTextFormat("[fa_top][fa_center][scale,0.5]").setTextValueAnchor({x: sprite_get_width(base4)/2, y: 0});
		}
	}
	
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
		with (add(new UIText("textwrap", 25, 100, "[c_red][fa_left][fa_top]This is an extremely long [c_lime]UIText item [c_blue] and should be wrapped accordingly"), 2)) {
			//setMaxWidth(self.getParent().getDimensions().width - 50);			
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_message("Click");
			});
		}
		
		with (add(new UICheckbox("toggle", 25, 100, "[fa_left][fa_middle][c_white]Sounds", spr_Toggle, false))) {
		}
		
		var _parent_w = self.getDimensions().width;
		var _parent_h = self.getDimensions().height;
		var _parent_start = self.getDragBarHeight();
		
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
		show_debug_message(getTabControl().getDimensions());
		setTabControlVisible(true);
		setSpriteTabBackground(red_panel);
		setTabControlAlignment(UI_RELATIVE_TO.TOP_LEFT);
		
		setTabSprite(0, grey_button00);
		setTabSprite(1, grey_button00);
		setTabSprite(2, grey_button00);
		setTabSpriteMouseover(0, green_button00);
		setTabSpriteMouseover(1, green_button00);
		setTabSpriteMouseover(2, green_button00);
		setTabSpriteSelected(0, green_button00);
		setTabSpriteSelected(1, green_button00);
		setTabSpriteSelected(2, green_button00);		
		var _fmt = "[c_black][fnt_Test]";
		var _fmtMO = "[c_gray][fnt_Test]";
		var _fmtS = "[c_white][fnt_Test]";
		setTabText(0, _fmt+"Options");
		setTabText(1, _fmt+"Prefs");
		setTabText(2, _fmt+"Settings");
		setTabTextMouseover(0, _fmtMO+"Options");
		setTabTextMouseover(1, _fmtMO+"Prefs");
		setTabTextMouseover(2, _fmtMO+"Settings");
		setTabTextSelected(0, _fmtS+"Options");
		setTabTextSelected(1, _fmtS+"Prefs");
		setTabTextSelected(2, _fmtS+"Settings");
		setTabSpecificSize(150);
		setTabSizeBehavior(UI_TAB_SIZE_BEHAVIOR.SPRITE);
		setTabSpacing(5);
		setTabOffset(10);
			
		
		setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
			if (keyboard_check(vk_shift)) {
				self.scroll(UI_ORIENTATION.HORIZONTAL, -1);
			}
			else {
				self.scroll(UI_ORIENTATION.VERTICAL, -1);
			}
		});
		setCallback(UI_EVENT.MOUSE_WHEEL_UP, function() {
			if (keyboard_check(vk_shift)) {
				self.scroll(UI_ORIENTATION.HORIZONTAL, 1);
			}
			else {
				self.scroll(UI_ORIENTATION.VERTICAL, 1);
			}
		});
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			if (keyboard_check(vk_shift)) {
				self.resetScroll(UI_ORIENTATION.HORIZONTAL);
			}
			else {
				self.resetScroll(UI_ORIENTATION.VERTICAL);
			}
		});
	}
	
	

	with (new UIPanel("Panel2", 454, 35, 300, 500, green_panel)) {
		setMovable(false);		
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
		setResizable(false);		
		setClipsContent(true);
		setDragBarHeight(90);
		setTitle("[fa_middle][c_white][fnt_Test_Outline]OPTIONS");
		setTitleAnchor(UI_RELATIVE_TO.MIDDLE_CENTER);
		//setTitleOffsetX(20);
		with (add(new UIText("OptText", 25, 70, "[fa_left][c_gray]General options"))) {
			setTextMouseover("[fa_left][c_blue]General options").setTextClick("[fa_left][c_blue]General options!!!").setBackgroundColor(c_red).setBorderColor(c_black);
		}
		add(new UIButton("Button3", 25, 100, 150, 50, "[c_white]Good luck",yellow_button00));
		add(new UIButton("Button4", 25, 180, 150, 50, "[c_white]Have Fun", yellow_button00));
		with (add(new UIGroup("testGroup", 200, 100, 300, 300, glassPanel))) {
			setClipsContent(true);
			setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
				if (keyboard_check(vk_shift)) {
					self.scroll(UI_ORIENTATION.HORIZONTAL, -1);
				}
				else {
					self.scroll(UI_ORIENTATION.VERTICAL, -1);
				}
			});
			setCallback(UI_EVENT.MOUSE_WHEEL_UP, function() {
				if (keyboard_check(vk_shift)) {
					self.scroll(UI_ORIENTATION.HORIZONTAL, 1);
				}
				else {
					self.scroll(UI_ORIENTATION.VERTICAL, 1);
				}
			});
			setCallback(UI_EVENT.MIDDLE_CLICK, function() {
				if (keyboard_check(vk_shift)) {
					self.resetScroll(UI_ORIENTATION.HORIZONTAL);
				}
				else {
					self.resetScroll(UI_ORIENTATION.VERTICAL);
				}
			});
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

		setCloseButtonSprite(yellow_boxCross);
		
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});
	}
	
	
	with (new UIPanel("Panel4", 778, 35, 400, 400, metalPanel)) {
		setCallback(UI_EVENT.RIGHT_CLICK, function() {
			show_debug_message("clicked");
		});	
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		add(new UIText("test", -10, -10, "[fa_left][c_black]this is a [c_red]test", UI_RELATIVE_TO.BOTTOM_RIGHT));
		var _fmt = "[fa_left][#eeeeee]";
		var _fmt_mouseover = "[fa_left][#009900]";
		var _fmt_selected = "[fa_left]";
		var _q = add(new UIDropdown("testdrop", 10, self.getDragBarHeight(), [_fmt+"1920x1080", _fmt+"3480x2160", _fmt+"1280x720", _fmt+"640x480", _fmt+"2560x1440"], green_button10, green_button09));
		_q.setDimensions(,,200).setSpriteMouseover(green_button08)
			.setOptionArrayMouseover([_fmt_mouseover+"1920x1080", _fmt_mouseover+"3480x2160", _fmt_mouseover+"1280x720", _fmt_mouseover+"640x480", _fmt_mouseover+"2560x1440"])
			.setOptionArraySelected([_fmt_selected+"1920x1080", _fmt_selected+"3480x2160", _fmt_selected+"1280x720", _fmt_selected+"640x480", _fmt_selected+"2560x1440"]);
		with (_q) {
			setCallback(UI_EVENT.VALUE_CHANGED, function() {
				show_message("Your new resolution is "+self.getOptionRawText());
			});
			setCallback(UI_EVENT.RIGHT_RELEASE, function() {
				show_debug_message("Yay");
			});
		}
		
		with (add(new UISprite("shieldSprite", 20, 20, 128, 128, spr_Shield, 1))) {			
			setAnimationSpeed(0.25, time_source_units_seconds,false);
			setAnimationStep(-5);
			animationStart();
		}
		
		setCloseButtonAnchor(UI_RELATIVE_TO.BOTTOM_RIGHT);
		setCloseButtonOffsetX(-10);
		setCloseButtonOffsetY(-10);
		setCloseButtonSprite(grey_boxCross);
		
	}
	
	with (new UIPanel("Panel5", 920, 35, 350, 400, red_panel)) {
		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
		});	
		
		
		with (add(new UISlider("slider1", 50, 100, 150, grey_sliderHorizontal, grey_sliderDown, 10, 5, 50, UI_ORIENTATION.HORIZONTAL))) {
			setSmallChange(1);
			setBigChange(5);
			setScrollChange(1);
			setShowMinMaxText(true);
			setShowHandleText(true);
			setTextFormat("[c_black]");
			setCallback(UI_EVENT.VALUE_CHANGED, function(_old, _new) {
				show_debug_message("Slider changed from {0} to {1}", _old, _new);
			});
		}
		
		with (add(new UISlider("scrollbar1", 50, 300, 150, spr_Scrollbar_Track, spr_Scrollbar_Handle, 0, 0, 100, UI_ORIENTATION.HORIZONTAL))) {
			setSmallChange(1);
			setBigChange(5);
			setScrollChange(1);
			setInheritLength(true);			
			setTextFormat("[c_black]");
			setCallback(UI_EVENT.VALUE_CHANGED, function(_old, _new) {
				UI.get("Panel1").setScrollOffset(UI_ORIENTATION.VERTICAL, self.getValue());
			});
		}
		
		with (add(new UICheckbox("slider checkbox", 200, 350, "[fa_left]Horizontal slider", grey_box, true))) {
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
		
		//with (add(new UICanvas("canvas1", 50, 500, 200, 200, obj_Game.mysurface))) {
		with (add(new UICanvas("canvas1", 0, 500, 300, 200, obj_Game.mysurface))) {
			setInheritWidth(true);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("clicking the suuuuuurface");
			});
		}
		
		setCallback(UI_EVENT.MOUSE_ENTER, function() {
			show_debug_message("entering the beauty of "+self.getID());
		});
		
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
		setMovable(false);
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
if (keyboard_check_pressed(vk_shift)) {
	UI.get("testdrop").__dropdown_active = !UI.get("testdrop").__dropdown_active;
}

if (keyboard_check(vk_right) && UI.exists("progress"))	UI.get("progress").setValue(UI.get("progress").getValue()+5);
if (keyboard_check(vk_left) && UI.exists("progress"))	UI.get("progress").setValue(UI.get("progress").getValue()-5);
if (keyboard_check(vk_up) && UI.exists("progress2"))	UI.get("progress2").setValue(UI.get("progress2").getValue()+2);
if (keyboard_check(vk_down) && UI.exists("progress2"))	UI.get("progress2").setValue(UI.get("progress2").getValue()-2);



if (keyboard_check_pressed(vk_f3)) {
	with (new UIPanel("modal", 0, 0, 500, 200, grey_panel, UI_RELATIVE_TO.MIDDLE_CENTER)) {
		with (add(new UIText("tit1", 10, 10, "[fa_top][fa_center][c_red]Sup man"))) {
			setBackgroundColor(#cccccc);
		}
		with (add(new UIText("tit2", 10, 10, "[fa_bottom][fa_right][c_lime]Yay", UI_RELATIVE_TO.BOTTOM_RIGHT))) {
			setBackgroundColor(#cccccc);
		}
		with (add(new UIText("txt", 0, 0, "[c_black]Do you really wish to continue?", UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setBackgroundColor(#cccccc);
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message(self.__dimensions);
			});
		}
		with (add(new UIButton("b1", -50, 40, 50, 30, "[fa_center][fa_middle]Yes", blue_button00, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("Accepted");
				self.getParent().destroy();
			});
		}
		with (add(new UIButton("b2", 50, 40, 50, 30, "[fa_center][fa_middle]No", red_button00, UI_RELATIVE_TO.MIDDLE_CENTER))) {
			setCallback(UI_EVENT.LEFT_CLICK, function() {
				show_debug_message("Declined");
				self.getParent().destroy();
			});
		}
		setModal(true);
	}
}