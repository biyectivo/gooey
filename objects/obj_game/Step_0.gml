if (live_call()) return live_result;
//show_debug_message(game_get_speed(gamespeed_fps));
if (keyboard_check_pressed(vk_escape))	game_restart();
if (keyboard_check_pressed(vk_f2))	UI.setScale(UI.getScale()+1);
if (keyboard_check_pressed(vk_f1))	UI.setScale(max(UI.getScale()-1, 1));


//if (!UI.exists("LevelSelectPanel")) {
//	var _num_levels = 60;
//	var _columns = 3;
	
//	var _panel = new UIPanel("LevelSelectPanel", 500, 200, 500, 500, blue_panel, UI_RELATIVE_TO.MIDDLE_CENTER);
//	_panel.setTitle("Level Select");
//	var _grid = new UIGrid("LevelsGrid", _num_levels div _columns, _columns);
//	_grid.setSpacingHorizontal(20).setSpacingVertical(20).setMarginLeft(50).setMarginRight(50).setMarginTop(10).setMarginBottom(10);
	
	
//	function _panel_up() {
//		UI.get("LevelSelectPanel").scroll(UI_ORIENTATION.VERTICAL, 1, 50);
//	}
//	function _panel_down() {
//		UI.get("LevelSelectPanel").scroll(UI_ORIENTATION.VERTICAL, -1, 50);
//	}
//	function _panel_reset() {
//		UI.get("LevelSelectPanel").resetScroll(UI_ORIENTATION.VERTICAL);
//	}
	
//	_grid.setCallback(UI_EVENT.MOUSE_WHEEL_UP, _panel_up).setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, _panel_down).setCallback(UI_EVENT.MIDDLE_CLICK, _panel_reset);
//	_panel.setCallback(UI_EVENT.MOUSE_WHEEL_UP, _panel_up).setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, _panel_down).setCallback(UI_EVENT.MIDDLE_CLICK, _panel_reset);
	
//for (var _level = 0; _level < _num_levels; _level++) {
//	var _button = new UIButton("Level"+string(_level+1), 0, 0, 0, 0 , "Level "+string(_level+1), blue_button00, UI_RELATIVE_TO.MIDDLE_CENTER);
//	_button.setInheritWidth(true).setInheritHeight(true).setCallback(UI_EVENT.LEFT_RELEASE, method({level: _level}, function() {
//		show_message("You selected level "+string(level+1));
//	}));
//	_grid.addToCell(_button, _level div _columns, _level % _columns);
//}
//	_panel.add(_grid);
//}

//if (keyboard_check(vk_down))	UI.get("LevelSelectPanel").scroll(UI_ORIENTATION.VERTICAL, 1, 1);
//if (keyboard_check(vk_up))		UI.get("LevelSelectPanel").scroll(UI_ORIENTATION.VERTICAL, -1, 1);




if (!UI.exists("LevelSelectPanel")) {
	var _num_levels = 30;
	var _columns = 3;
	
	var _panel = new UIPanel("LevelSelectPanel", 500, 200, 500, 500, blue_panel, UI_RELATIVE_TO.MIDDLE_CENTER);
	_panel.setTitle("Level Select").setTitleAnchor(UI_RELATIVE_TO.MIDDLE_CENTER);
	
	var _container = new UIGrid("ContainerGrid", 2, 1);
	_container.setRowProportions([0.2, 0.8]);
	_container.setShowGridOverlay(true);
	_container.getCell(1,0).setClipsContent(true);
	
	var _cnt = _container.addToCell(new UIGroup("GridContainer", 0, 0, 500, 1500, red_panel), 1, 0);
	
	var _grid = new UIGrid("LevelsGrid", _num_levels div _columns, _columns);
	_grid.setSpacingHorizontal(20).setSpacingVertical(20).setMarginLeft(50).setMarginRight(50).setMarginTop(10).setMarginBottom(10);
	
	
	for (var _level = 0; _level < _num_levels; _level++) {
		var _button = new UIButton("Level"+string(_level+1), 0, 0, 0, 0 , "Level "+string(_level+1), blue_button00, UI_RELATIVE_TO.MIDDLE_CENTER);
		_button.setSpriteMouseover(blue_button01).setInheritWidth(true).setInheritHeight(true).setCallback(UI_EVENT.LEFT_RELEASE, method({level: _level}, function() {
			show_message("You selected level "+string(level+1));
			UI.get("Level"+string(level+1)).setSprite(red_button00);
		}));
		_grid.addToCell(_button, _level div _columns, _level % _columns);
	}
	_container.addToCell(_cnt, 1, 0);
	_cnt.add(_grid);
	_panel.add(_container);
}

if (keyboard_check(vk_down))	UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.VERTICAL, -1, 5);
if (keyboard_check(vk_up))		UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.VERTICAL, 1, 5);
if (keyboard_check(vk_right))	UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.HORIZONTAL, -1, 5);
if (keyboard_check(vk_left))	UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.HORIZONTAL, 1, 5);

//function _panel_up() {
//		UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.VERTICAL, 1, 50);
//	}
//	function _panel_down() {
//		UI.get("ContainerGrid").getCell(1,0).scroll(UI_ORIENTATION.VERTICAL, -1, 50);
//	}
//	function _panel_reset() {
//		UI.get("ContainerGrid").getCell(1,0).resetScroll(UI_ORIENTATION.VERTICAL);
//	}
	
	
	
//_grid.setCallback(UI_EVENT.MOUSE_WHEEL_UP, _panel_up).setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, _panel_down).setCallback(UI_EVENT.MIDDLE_CLICK, _panel_reset);
//_panel.setCallback(UI_EVENT.MOUSE_WHEEL_UP, _panel_up).setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, _panel_down).setCallback(UI_EVENT.MIDDLE_CLICK, _panel_reset);
	
//if (UI.get("testText")) {
//	UI.get("testText").setDimensions(50, -50,,,UI_RELATIVE_TO.BOTTOM_LEFT);
//	UI.get("testText").setText("[fa_middle][fa_left]"+keyboard_string);
//	UI.get("testText").setTextMouseover("[fa_middle][fa_left][c_lime]"+keyboard_string);
//	UI.get("testText").setTextClick("[fa_middle][fa_left][c_yellow]"+keyboard_string);
//	UI.get("testText").setBackgroundColor(#ff0000);
//}


//self.current_step++;
//self.current_step_method = function() {
//	return "Good luck! [c_red]"+string(self.current_step) + "[c_white]";
//}

//self.text_method = function() {
//	return "This [c_lime]is [/color] a regular text with "+string(fps_real) + "fps";
//}

//self.progress_method = function() {
//	return fps_real;
//}

//if (keyboard_check_pressed(ord("Q")))	{
//	UI.get("slider1").setClickToSet(!UI.get("slider1").getClickToSet());
//	show_debug_message(string("{0} {1}", UI.get("slider1").getClickToSet()));
//}


//if (!self.widgets_created && keyboard_check_pressed(vk_space)) {
//	self.widgets_created = true;
	
//	with (new UIPanel("test", 100, 100, 500, 500, blue_panel)) {
//		add(new UIText("testText", 0, -50, "[fa_left][fa_top]"+keyboard_string, UI_RELATIVE_TO.BOTTOM_CENTER));
//	}

//	with (new UIPanel("aaa", 0, 0, 300, 300, transparent, UI_RELATIVE_TO.BOTTOM_LEFT)) {		
//		setMovable(false);
//		setResizable(false);		
//		with (add(new UIProgressBar("progress", 0, 0, base4, progress3, 10, 0, 100))) {
//			setSpriteProgressAnchor({x: 0, y: sprite_get_height(base4)});
//			setOrientation(UI_ORIENTATION.VERTICAL);
//			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL);
//			setProgressRepeatUnit(20);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message(self.getValue());
//			});
//		}
		
//		with (add(new UIProgressBar("progress2", 20, 0, base4, progress4, 10, 0, 100))) {
//			setSpriteProgressAnchor({x: 0, y: sprite_get_height(base4)});
//			setOrientation(UI_ORIENTATION.VERTICAL);
//			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH);
//			setProgressRepeatUnit(20);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message(self.getValue());
//			});
//			setShowValue(true).setPrefix("$").setSuffix(" mln").setTextFormat("[fa_top][fa_center][scale,0.5]").setTextValueAnchor({x: sprite_get_width(base4)/2, y: 0});
//		}
		
//		with (add(new UIProgressBar("progress3", 50, 0, transparent, heart, 3, 0, 5))) {
//			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT);			
//			setSpriteRemainingProgress(empty_heart);
//		}
		
//		with (add(new UIProgressBar("progress4", 100, 0, base4, progress3, 100, 0, 1000))) {
//			setSpriteProgressAnchor({x: 0, y: sprite_get_height(base4)});
//			setOrientation(UI_ORIENTATION.VERTICAL);
//			setRenderProgressBehavior(UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				self.clearBinding();
//			});
//			setCallback(UI_EVENT.RIGHT_CLICK, function() {
//				self.setBinding(obj_Game, "progress_method");
//			});
//		}
//	}
	
//	with (new UIPanel("PanelGrid", 800, 200, 500, 500, blue_panel)) {
//		setCloseButtonSprite(red_cross);
		
//		with (add(new UIGrid("grid", 4, 3))) {
//			setShowGridOverlay(true);
//			setMarginLeft(5);
//			setMarginRight(5);			
//			setMarginBottom(60)
//			setMarginTop(self.getParent().getDragBarHeight());
//			setSpacingHorizontal(5);
//			setSpacingVertical(15);
//			setRowProportions([0.2, 0.3, 0.3, 0.2]);
//			setColumnProportions([0.2, 0.7, 0.1]);
//			with(addToCell(new UIButton("hola", 0, 0,  180, 60, "End game", blue_button08, UI_RELATIVE_TO.MIDDLE_CENTER), 2, 0)) {
//				setInheritWidth(true);
//				setInheritHeight(true);
//				setCallback(UI_EVENT.LEFT_RELEASE, window_center);
//			}
//			with(addToCell(new UIButton("hola2", 0, 0,  180, 60, "Hi world", blue_button08, UI_RELATIVE_TO.MIDDLE_CENTER), 2, 1)) {
//				setInheritWidth(true);
//				setInheritHeight(true);
//			}
//			with(addToCell(new UIButton("hola3", 0, 0,  180, 60, "Hi world", blue_button08, UI_RELATIVE_TO.MIDDLE_CENTER), 2, 2)) {
//				setInheritWidth(true);
//				setInheritHeight(true);
//			}
//			with(addToCell(new UIGrid("grid2", 1, 3), 0, 1)) {
//				setSpacings(20);
//				setMargins(10);
				
//				var _slider = addToCell(new UISlider("ControlPanel_PersistenceSlider", 0, 0, 300, grey_sliderHorizontal, grey_sliderUp, 50, 20, 100, , UI_RELATIVE_TO.MIDDLE_CENTER), 0, 2);
//				with (_slider) {
//					setSpriteHandleMouseover(blue_sliderUp);
//					setClickChange(5);
//					setDragChange(10);
//					setScrollChange(20);
//					setTextFormat("[fa_center][c_black]");
//					setCallback(UI_EVENT.VALUE_CHANGED, function() {
//						//show_debug_message(UI.get("ControlPanel_PersistenceSlider").getValue());
//					});
//				}
//			}
//			getCell(0,0).setSprite(blue_panel);
//		}
//	}
	
	
//	with (new UIPanel("Panel1", 20, 35, 400, 600, blue_panel)) {		
//		// First tab
//		with (add(new UIButton("Button1", 25, 50, 200, 50, "[c_white]Enabled Panel3", blue_button00))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("Panel3"))	UI.get("Panel3").setEnabled(!UI.get("Panel3").getEnabled());
//			});
//		}
//		addTab(2);
//		// Second tab
//		with (add(new UIButton("Button1 Second Tab", 25, 50, 200, 50, "[c_white]Alert", blue_button00), 1)) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_message("Sup");
//			});
//		}
//		//addTab();
//		// Third tab
//		with (add(new UIButton("Button1 third Tab", 25, 50, 200, 50, "[c_white]center me", yellow_button00, UI_RELATIVE_TO.MIDDLE_CENTER), 2)) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				window_center();
//			});
//		}
//		with (add(new UIText("textwrap", 25, 100, "[c_red][fa_left][fa_top]This is an extremely long [c_lime]UIText item [c_blue] and should be wrapped accordingly"), 2)) {
//			setMaxWidth(self.getParent().getDimensions().width - 50);			
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_message("Click");
//			});
//		}
		
//		with (add(new UICheckbox("toggle", 25, 100, "[fa_left][fa_middle][c_white]Sounds", spr_Toggle, spr_Toggle, false))) {
//			setImageTrue(1);
//			setImageMouseoverTrue(1);
//		}
		
//		var _parent_w = self.getDimensions().width;
//		var _parent_h = self.getDimensions().height;
//		var _parent_start = self.getDragBarHeight();
		
//		add(new UIText("gaa", 0, -30, "[jitter][#152499][fa_center][fa_bottom]This text should appear regardless of tab[/jitter]", UI_RELATIVE_TO.BOTTOM_CENTER), -1);
//		with (add(new UIText("gaa", 0, -10, "DEFAULT UGLY FIXED TEXT", UI_RELATIVE_TO.BOTTOM_CENTER), -1)) {
//			setBinding(obj_Game, "text_method");			
//		}
		
		
//		setCallback(UI_EVENT.RIGHT_CLICK, function() {
//			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//		});	
		
//		with (add(new UICheckbox("test checkbox right", 0, 150, "[fa_left]Antialias checkbox (off)", blue_boxCheckmark, -1, true, UI_RELATIVE_TO.TOP_CENTER))) {
//			setSpriteBase(checkbox_off);
//			setSpriteMouseoverTrue(red_boxCheckmark);
//			setTextOffset({x: 10, y: 0});
//			setTextTrue("[fa_left]Antialias checkbox (on)");
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("antialias"))	UI.get("antialias").setEnabled(!UI.get("antialias").getEnabled());
//			});
//		}
//		with (add(new UICheckbox("test checkbox right2", 0, 250, "[fa_left]Antialias visible", yellow_boxCross, -1, true, UI_RELATIVE_TO.TOP_CENTER))) {
//			setSpriteBase(checkbox_off);
//			setSpriteMouseoverTrue(yellow_boxCross);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("antialias"))	UI.get("antialias").setVisible(!UI.get("antialias").getVisible());
//			});
//		}
//		setCloseButtonSprite(blue_boxCross);
		
//		setImageAlpha(0.4);
//		show_debug_message(getTabControl().getDimensions());
//		setTabControlVisible(true);
//		setSpriteTabBackground(red_panel);
//		setTabControlAlignment(UI_RELATIVE_TO.TOP_LEFT);
		
//		setTabSprite(0, grey_button00);
//		setTabSprite(1, grey_button00);
//		setTabSprite(2, grey_button00);
//		setTabSpriteMouseover(0, green_button00);
//		setTabSpriteMouseover(1, green_button00);
//		setTabSpriteMouseover(2, green_button00);
//		setTabSpriteSelected(0, green_button00);
//		setTabSpriteSelected(1, green_button00);
//		setTabSpriteSelected(2, green_button00);		
//		var _fmt = "[c_black][fnt_Test]";
//		var _fmtMO = "[c_gray][fnt_Test]";
//		var _fmtS = "[c_white][fnt_Test]";
//		setTabText(0, _fmt+"Options");
//		setTabText(1, _fmt+"Prefs");
//		setTabText(2, _fmt+"Settings");
//		setTabTextMouseover(0, _fmtMO+"Options");
//		setTabTextMouseover(1, _fmtMO+"Prefs");
//		setTabTextMouseover(2, _fmtMO+"Settings");
//		setTabTextSelected(0, _fmtS+"Options");
//		setTabTextSelected(1, _fmtS+"Prefs");
//		setTabTextSelected(2, _fmtS+"Settings");
//		setTabSpecificSize(150);
//		setTabSizeBehavior(UI_TAB_SIZE_BEHAVIOR.SPRITE);
//		setTabSpacing(5);
//		setTabOffset(10);
			
		
//		setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
//			if (keyboard_check(vk_shift)) {
//				self.scroll(UI_ORIENTATION.HORIZONTAL, -1);
//			}
//			else {
//				self.scroll(UI_ORIENTATION.VERTICAL, -1);
//			}
//		});
//		setCallback(UI_EVENT.MOUSE_WHEEL_UP, function() {
//			if (keyboard_check(vk_shift)) {
//				self.scroll(UI_ORIENTATION.HORIZONTAL, 1);
//			}
//			else {
//				self.scroll(UI_ORIENTATION.VERTICAL, 1);
//			}
//		});
//		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
//			if (keyboard_check(vk_shift)) {
//				self.resetScroll(UI_ORIENTATION.HORIZONTAL);
//			}
//			else {
//				self.resetScroll(UI_ORIENTATION.VERTICAL);
//			}
//		});
//	}
	
	

//	with (new UIPanel("Panel2", 454, 35, 300, 500, green_panel)) {
//		setMovable(false);		
//		with (add(new UIButton("Button2", 25, 40, 200, 50, "[c_white]Visible Panel3", green_button00))) {
//			setTextFormat("[fa_left][fa_middle]");
//			setTextFormatMouseover("[fa_left][fa_middle]");
//			setTextFormatClick("[fa_left][fa_middle]");
//			setTextFormatDisabled("[fa_left][fa_middle]");
//			setTextOffset({x: 15, y: 0});
//			setTextRelativeTo(UI_RELATIVE_TO.MIDDLE_LEFT);
//			setSpriteMouseover(green_button01);
//			setSpriteClick(green_button02);
//			setTextMouseover("[c_black]Visible Panel3");
//			setTextClick("[c_lime]Visible Panel3");
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("Panel3"))	UI.get("Panel3").setVisible(!UI.get("Panel3").getVisible());
//			});
//			setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
//				show_debug_message("Wheelie");
//			});
//		}
//		setCallback(UI_EVENT.RIGHT_RELEASE, function() {
//			show_debug_message(self.__ID+": "+string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//		});	
		
//		with (add(new UICheckbox("antialias", 25, 100, "Enable antialias", green_boxCheckmark, -1))) {
//			setTextTrue("Disable antialias");
//			setTextFormatTrue("[fa_left][c_white]");
//			setTextFormatFalse("[fa_left][c_white]");
//			setTextFormatMouseoverFalse("[fa_left][c_red]");
//			setTextFormatMouseoverTrue("[fa_left][c_red]");
//			setTextFormatTrue("[fa_left][c_white]");
//			setSpriteBase(checkbox_off);
//			setSpriteMouseoverTrue(green_boxCheckmark);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message("toggled")
//			});
//			setCallback(UI_EVENT.RIGHT_CLICK, function() {
//				show_debug_message("right click on checkbox")
//				show_debug_message(self.__ID+": "+string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//			});
//			setEnabled(true);
//			setCallback(UI_EVENT.VALUE_CHANGED, function() {
//				show_debug_message("Antialias checkbox changed");
//			});
//		}
		
//		setCallback(UI_EVENT.RIGHT_CLICK, function() {
//			if (UI.exists("antialias")) show_debug_message(UI.get("antialias").getValue());
//		});	
		
//		with (add(new UITextBox("textbox1", 25, 200, 200, 100, grey_panel))) {
//			setPlaceholderText("Type something...");
//			setTextFormat("[fa_left][fa_top][c_black][fnt_Test3]");
//			setAllowUppercaseLetters(false);
//			setAllowSpaces(false);
//			setAllowSymbols(true);
//			setAllowDigits(true);
//			setSymbolsAllowed(".,-");			
//		}
		
//		with (add(new UITextBox("textbox2", 25, 300, 200, 100, grey_panel))) {
//			setPlaceholderText("Something else...");
//			setTextFormat("[fa_left][fa_top][c_blue]");			
//		}
		
//		add(new UIText("txtuser", 25, 280, "USERNAME"));
		
//		with (add(new UIButton("textbox1_mask", 25, 400, 100, 30, "Mask/unmask", red_button00))) {
//			setTextFormat("[c_white]");
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("textbox1"))	UI.get("textbox1").setMaskText(!UI.get("textbox1").getMaskText());
//			});
//			setCallback(UI_EVENT.RIGHT_CLICK, function() {
//				if (UI.exists("antialias"))	UI.get("antialias").toggle();
//			});
//		}
		
		
//		with (add(new UIButton("textbox1_maxchar", 25, 450, 100, 30, "Max 10 chars", red_button00))) {
//			setTextFormat("[c_white]");
			
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(10);
//			});
//			setCallback(UI_EVENT.RIGHT_CLICK, function() {
//				if (UI.exists("textbox1"))	UI.get("textbox1").setMaxChars(0);
//			});
//		}
		
//		with (add(new UICheckbox("slider checkbox", 25, 500, "textbox2 read only", red_boxCheckmark, -1, false))) {
//			setSpriteBase(grey_box);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("textbox2"))	UI.get("textbox2").setReadOnly(!UI.get("textbox2").getReadOnly());
//			});
//		}
		
		
//		setCloseButtonSprite(green_boxCross);
//	}
			
//	with (new UIPanel("Panel3", 1371, 35, 480, 480, yellow_panel)) {
//		setResizable(false);		
//		setClipsContent(true);
//		setDragBarHeight(90);
//		setTitleFormat("[fa_middle][c_white][fnt_Test_Outline]");
//		setTitle("OPTIONS");
//		setTitleAnchor(UI_RELATIVE_TO.MIDDLE_CENTER);
//		//setTitleOffset({x: 20, y: 0});
//		with (add(new UIText("OptText", 25, 70, "[fa_left][c_gray]General options"))) {
//			setTextMouseover("[fa_left][c_blue]General options").setTextClick("[fa_left][c_blue]General options!!!").setBackgroundColor(c_red).setBorderColor(c_black);
//		}
//		with (add(new UIButton("Button3", 25, 100, 150, 50, "[c_white]Good luck",yellow_button00))) {
//			setSpriteDisabled(grey_button00);
//			setCallback(UI_EVENT.LEFT_RELEASE, function() {
//				show_message("Hi :)");
//			});
//			setCallback(UI_EVENT.MOUSE_ENTER, function() {
//				show_debug_message("ENTERED Button3 GL");
//			});
//			setCallback(UI_EVENT.MOUSE_EXIT, function() {
//				show_debug_message("EXITED Button3 GL");
//			});
//			//setBinding(obj_Game, "current_step_method");
//			setBinding(obj_Game, "current_step");
//			setTextFormatMouseover("[c_red]");
//			setTextFormatDisabled("[c_gray]");
			
//		}
//		with(add(new UIButton("Button4", 25, 180, 150, 50, "[c_white]Have Fun", yellow_button00))) {
//			setCallback(UI_EVENT.LEFT_RELEASE, function() {
//				if (UI.exists("Button3"))	UI.get("Button3").setEnabled(!UI.get("Button3").getEnabled());
//			});
//			setPreRenderCallback(function() {
//				self.setVisible(device_mouse_x(0) > display_get_gui_width()/2);
//			});
//		}
//		with (add(new UIGroup("testGroup", 200, 100, 300, 300, glass_panel))) {
//			setClipsContent(true);			
//			setCallback(UI_EVENT.MOUSE_WHEEL_DOWN, function() {
//				if (keyboard_check(vk_shift)) {
//					self.scroll(UI_ORIENTATION.HORIZONTAL, -1);
//				}
//				else {
//					self.scroll(UI_ORIENTATION.VERTICAL, -1);
//				}
//			});
//			setCallback(UI_EVENT.MOUSE_WHEEL_UP, function() {
//				if (keyboard_check(vk_shift)) {
//					self.scroll(UI_ORIENTATION.HORIZONTAL, 1);
//				}
//				else {
//					self.scroll(UI_ORIENTATION.VERTICAL, 1);
//				}
//			});
//			setCallback(UI_EVENT.MIDDLE_CLICK, function() {
//				if (keyboard_check(vk_shift)) {
//					self.resetScroll(UI_ORIENTATION.HORIZONTAL);
//				}
//				else {
//					self.resetScroll(UI_ORIENTATION.VERTICAL);
//				}
//			});
//			with (add(new UIButton("Button6", 20, 20, 100, 50, "[c_white]A",red_button00))) {
//				setCallback(UI_EVENT.LEFT_CLICK, function() {
//					show_debug_message("selected A " + self.__ID);
//				});
//			}
			
//			with (add(new UIButton("Button7", 20, 80, 100, 50, "[c_white]B",red_button00))) {
//				setCallback(UI_EVENT.LEFT_CLICK, function() {
//					show_debug_message("selected B");
//				});
//				setSpriteMouseover(yellow_button00);
//				setSpriteClick(blue_button00);
//				setTextMouseover("[c_red]B");
//				setTextClick("[c_lime]B");
//			}
//		}

//		setCloseButtonSprite(yellow_boxCross);
		
//		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
//			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//		});
//	}
	
	
//	with (new UIPanel("Panel4", 778, 35, 400, 400, metalPanel)) {
//		setCallback(UI_EVENT.RIGHT_CLICK, function() {
//			show_debug_message("clicked");
//		});	
//		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
//			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//		});	
		
//		add(new UIText("test", -10, -10, "[fa_left][c_black]this is a [c_red]test", UI_RELATIVE_TO.BOTTOM_RIGHT));
//		var _fmt = "[fa_left][#eeeeee]";
//		var _fmt_mouseover = "[fa_left][#009900]";
//		var _fmt_selected = "[fa_left]";
//		var _array =  ["1920x1080", "3480x2160", "1280x720", "640x480", "2560x1440"];
//		var _q = add(new UIDropdown("testdrop", 10, self.getDragBarHeight(), _array, green_button10, green_button09));
//		_q.setDimensions(,,200).setSpriteMouseover(green_button08)
//			.setTextFormatUnselected(_fmt).setTextFormatSelected(_fmt_selected).setTextFormatMouseover(_fmt_mouseover);
//		with (_q) {
//			setCallback(UI_EVENT.VALUE_CHANGED, function() {
//				show_message("Your new resolution is "+self.getOptionRawText());
//			});
//			setCallback(UI_EVENT.RIGHT_RELEASE, function() {
//				show_debug_message("Yay");
//			});
//		}
		
//		with (add(new UISprite("shieldSprite", 20, 20, spr_Shield,,,1))) {			
//			setAnimationSpeed(0.25, time_source_units_seconds,false);
//			setAnimationStep(-5);
//			animationStart();
//			setCallback(UI_EVENT.RIGHT_RELEASE, function() {
//				setDimensions(,,32, 32);
//			});
//		}
		
		
//		setCloseButtonAnchor(UI_RELATIVE_TO.BOTTOM_RIGHT);
//		setCloseButtonOffset({x: -10, y: -10});
//		setCloseButtonSprite(grey_boxCross);
		
//	}

//	with (new UIPanel("test1234W", 100, 100, 64, 64, blue_panel, UI_RELATIVE_TO.MIDDLE_CENTER)) {
//		var _X = add(new UISprite("a", 0, 0, heart,,,,UI_RELATIVE_TO.MIDDLE_CENTER));
//		_X.setCallback(UI_EVENT.MOUSE_ENTER, function() {
//			show_debug_message("enter");
//		}).setCallback(UI_EVENT.MOUSE_EXIT, function() {
//			show_debug_message("exit");
//		});
//	}

//	with (new UIPanel("Panel5", 920, 35, 350, 400, red_panel)) {
//		setCallback(UI_EVENT.MIDDLE_CLICK, function() {
//			show_debug_message(string(self.getDimensions().x)+","+string(self.getDimensions().y)+" "+string(self.getDimensions().width)+"x"+string(self.getDimensions().height));
//		});	
		
//		with (add(new UITextBox("textbox1", 25, 200, 200, 100, grey_panel))) {
//			setPlaceholderText("Type something...");
//			setTextFormat("[fa_left][fa_top][c_black][fnt_Test3]");
//			setAllowUppercaseLetters(false);
//			setAllowSpaces(true);
//			setAllowSymbols(true);
//			setAllowDigits(true);
//			setSymbolsAllowed(".,-");
//			setMultiline(true);
//		}
		
//		with (add(new UISlider("slider1", 100, 100, 200, grey_sliderHorizontal, grey_sliderDown, 11, 5, 25, UI_ORIENTATION.HORIZONTAL))) {
//			setSpriteHandleMouseover(blue_sliderDown);
//			//setDragChange(2).setClickChange(2).setScrollChange(4);
//			setDragChange(0.25).setClickChange(1).setScrollChange(2);
//			setShowMinMaxText(true);
//			setShowHandleText(true);
//			setHandleOffset({x: 0, y: -30});
//			//setHandleTextOffset({x: 0, y: 20});
//			setTextFormat("[c_black][fa_left]");
//			setCallback(UI_EVENT.VALUE_CHANGED, function(_old, _new) {
//				show_debug_message("Slider changed from {0} to {1}", _old, _new);
//			});
//		}
		
//		//with (add(new UISlider("scrollbar1", 50, 800, 150, spr_Scrollbar_Track, spr_Scrollbar_Handle, 0, 0, 100, UI_ORIENTATION.HORIZONTAL))) {
//		//	setDragChange(1);
//		//	setClickChange(5);
//		//	setScrollChange(1);
//		//	setInheritLength(true);			
//		//	setTextFormat("[c_black]");
//		//	setCallback(UI_EVENT.VALUE_CHANGED, function(_old, _new) {
//		//		if (UI.exists("Panel1")) UI.get("Panel1").setScrollOffset(UI_ORIENTATION.VERTICAL, self.getValue());
//		//	});
//		//}
		
//		with (add(new UICheckbox("slider checkbox", 200, 350, "[fa_left]Horizontal slider", red_boxCheckmark, grey_box, true))) {
//			setSpriteBase(grey_box);			
//			setSpriteMouseoverTrue(red_boxCheckmark);			
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("slider1")) {
//					with (UI.get("slider1")) {						
//						if (getOrientation() == UI_ORIENTATION.HORIZONTAL) {
//							setSpriteBase(grey_sliderVertical);
//							setSpriteHandle(grey_sliderRight);
//							setSpriteHandleMouseover(blue_sliderRight);
//							setOrientation(UI_ORIENTATION.VERTICAL);
//							setHandleOffset({x: -30, y: 0});
//						}
//						else {
//							setSpriteBase(grey_sliderHorizontal);
//							setSpriteHandle(grey_sliderDown);
//							setSpriteHandleMouseover(blue_sliderDown);
//							setOrientation(UI_ORIENTATION.HORIZONTAL);							
//							setHandleOffset({x: 0, y: -30});
//						}
//					}
//				}
//			});
//		}
		
//		////with (add(new UICanvas("canvas1", 50, 500, 200, 200, obj_Game.surface_id))) {
//		//with (add(new UICanvas("canvas1", 0, 500, 300, 200, obj_Game.surface_id))) {
//		//	setInheritWidth(true);
//		//	setCallback(UI_EVENT.LEFT_CLICK, function() {
//		//		show_debug_message("clicking the suuuuuurface");
//		//	});
//		//}
		
//		setCallback(UI_EVENT.MOUSE_ENTER, function() {
//			show_debug_message("entering the beauty of "+self.getID());
//		});
		
//		setCloseButtonSprite(red_boxCross);
//	}

//if (keyboard_check_pressed(vk_space)) {
//	var _id = new UIPanel("Panel6", 920, 550, 600, 800, blue_panel);
//	_id.setTitle("[fa_right][fa_top][rainbow]Chaining Test       ").setTitleAnchor(UI_RELATIVE_TO.TOP_RIGHT).setCloseButtonSprite(blue_boxCross);
	
	
//	var _grp = new UIGroup("test", 0, 0, 500, 700, red_panel, UI_RELATIVE_TO.MIDDLE_CENTER);
//	_grp.setClipsContent(true);
//	var _fmt = "[fa_left][c_white]";
//	var _selfmt = "[fa_left][c_red]";
//	with (_grp.add(new UIOptionGroup("testgroup", 32, 50, [_fmt+"The option", _fmt+"Really freaking big option", _fmt+"Mini", _fmt+"The big blue boot"], grey_circle))) {
//		setOptionArraySelected([_selfmt+"The option", _selfmt+"Really freaking big option", _selfmt+"Mini", _selfmt + "The big blue boot"]);
//		setSpriteSelected(grey_boxTick);
//		setSpacing(15);
//		setCallback(UI_EVENT.VALUE_CHANGED, function() {
//			show_debug_message(self.__ID+" I changed. The Option")
//		});
//	}
//	_id.add(_grp);
	
//	var _fmt = "[fa_center][c_blue]";
//	var _array = ["The option", "Really freaking big option", "Mini", "The big blue boot"];
//	with (_id.add(new UISpinner("Spinner1", 32, 200, _array, grey_panel, grey_sliderLeft, grey_sliderRight, 350, 50))) {
//		self.getButtonLeft().setText("<").setTextMouseover("<").setTextFormat(_fmt).setTextFormatMouseover("[fa_center][fa_middle][c_red]");
//		self.getButtonRight().setText(">").setTextMouseover(">").setTextFormat(_fmt).setTextFormatMouseover("[fa_center][fa_middle][c_orange]") ;
//		self.getButtonText().setTextFormat(_fmt).setTextFormatMouseover("[fa_center][fa_middle][c_red]");
//		//self.getGrid().setColumnProportions([0.15,0.7,0.15]);
//		self.setCallback(UI_EVENT.VALUE_CHANGED, function(_old, _new) {
//			show_debug_message(string("I changed from {0} to {1}", _old, _new));
//		});
//		self.__button_text.setCallback(UI_EVENT.LEFT_CLICK, method({button_id: self.getButtonText().__ID, button_left: self.getButtonLeft().__ID}, function() {
//			show_debug_message(UI.get(button_id).getRawText());
//			show_message(UI.get(button_left).getTextFormatMouseover()); 
//		}));
//	}
	
	
//}

//if (keyboard_check_pressed(vk_enter)) {
//	show_debug_message(UI.get("testgroup").getDimensions());
//	show_debug_message(UI.get("Spinner1").getDimensions());
//}
//if (keyboard_check(vk_up) && keyboard_check(vk_shift))			UI.get("test").scroll(UI_ORIENTATION.VERTICAL, -1, 10);
//if (keyboard_check(vk_down) && keyboard_check(vk_shift))		UI.get("test").scroll(UI_ORIENTATION.VERTICAL, 1, 10);
//if (keyboard_check(vk_left) && keyboard_check(vk_shift))		UI.get("test").scroll(UI_ORIENTATION.HORIZONTAL, -1, 10);
//if (keyboard_check(vk_right) && keyboard_check(vk_shift))		UI.get("test").scroll(UI_ORIENTATION.HORIZONTAL, 1, 10);
//if (keyboard_check(vk_up) && !keyboard_check(vk_shift))			UI.get("Panel6").scroll(UI_ORIENTATION.VERTICAL, -1, 10);
//if (keyboard_check(vk_down) && !keyboard_check(vk_shift))		UI.get("Panel6").scroll(UI_ORIENTATION.VERTICAL, 1, 10);
//if (keyboard_check(vk_left) && !keyboard_check(vk_shift))		UI.get("Panel6").scroll(UI_ORIENTATION.HORIZONTAL, -1, 10);
//if (keyboard_check(vk_right) && !keyboard_check(vk_shift))		UI.get("Panel6").scroll(UI_ORIENTATION.HORIZONTAL, 1, 10);	

//	with (new UIPanel("Toolbar", 0, 0, 300, 80, glass_panel, UI_RELATIVE_TO.BOTTOM_CENTER)) {
//		setMovable(false);
//		setResizable(false);
//		with(add(new UIButton("Option1", -100, 0, 50, 50, "O1", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message("Toggling group orientation");
//				if (UI.exists("testgroup"))	UI.get("testgroup").setVertical(!UI.get("testgroup").getVertical());
//			});
//		}
//		with(add(new UIButton("Option2", -35, 0, 50, 50, "O2", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				if (UI.exists("textbox2"))	show_debug_message(UI.get("textbox1").getDimensions().height);
//				if (UI.exists("testgroup")) show_debug_message( string(UI.get("testgroup").getIndex())+" "+UI.get("testgroup").getOptionRawText() );
//				if (UI.exists("Panel6_TabControl_Group_TabButton0")) {
//					show_debug_message(string(UI.get("Panel6_TabControl_Group_TabButton0").getVisible())+" "+string(UI.get("Panel6_TabControl_Group_TabButton0").getEnabled()));
//					show_debug_message(string(UI.get("Panel6_TabControl_Group_TabButton1").getVisible())+" "+string(UI.get("Panel6_TabControl_Group_TabButton1").getEnabled()));
//				}
//			});
//		}
//		with(add(new UIButton("Option3", 35, 0, 50, 50, "O3", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				//show_debug_message("Selected toolbar 3");
//				show_debug_message(keyboard_string);
//			});
//		}
//		with(add(new UIButton("Option4", 100, 0, 50, 50, "O4", red_button06, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message("Selected toolbar 4");
//				if (UI.exists("textbox1"))	show_debug_message(UI.get("textbox1").getText());
//				if (UI.exists("textbox2"))	show_debug_message(UI.get("textbox2").getText());								
//			});
//		}
		
//	}
	
//}


//if (keyboard_check_pressed(ord("X"))) {
//	if (UI.exists("Panel3"))	UI.get("Panel3").setClipsContent(!UI.get("Panel3").getClipsContent())
//}

//if (keyboard_check_pressed(ord("Z"))) {
//	if (UI.exists("Panel3"))	{
//		var _p = UI.get("Panel3").getChildren();
//		for (var _i=0, _n=array_length(_p); _i<_n; _i++) show_debug_message(_p[_i].__ID);
//	}
//}

////UI.get("Panel3").setCloseButtonSprite(noone);


////if (UI.exists("Toolbar"))	UI.get("Toolbar").destroy();
//// Tabs
//if (keyboard_check_pressed(ord("I")) && UI.exists("Panel1"))	UI.get("Panel1").addTab(); 
 
//if (keyboard_check_pressed(ord("P")) && UI.exists("Panel1"))	UI.get("Panel1").nextTab(true); 
//if (keyboard_check_pressed(ord("O")) && UI.exists("Panel1"))	UI.get("Panel1").previousTab(true); 
//if (keyboard_check_pressed(ord("L")) && UI.exists("Panel1"))	UI.get("Panel1").removeTab(); 
//if (keyboard_check_pressed(ord("D")) && UI.exists("textbox2"))	UI.get("textbox2").destroy(); 
	
//if (keyboard_check_pressed(ord("V")) && UI.exists("Button7"))	show_message(UI.get("Button7").getContainingPanel().__ID); 
//if (keyboard_check_pressed(ord("B")) && UI.exists("Button1 Second Tab"))	show_message(UI.get("Button1 Second Tab").getContainingTab()); 
//if (keyboard_check_pressed(ord("N")) && UI.exists("gaa"))	show_message(UI.get("gaa").getContainingTab()); 
//if (keyboard_check_pressed(ord("F")) && UI.exists("Panel1"))	UI.get("Panel1").setVerticalTabs(!UI.get("Panel1").getVerticalTabs());
//if (keyboard_check_pressed(ord("G")) && UI.exists("Panel1"))	UI.get("Panel1").setTabControlAlignment(UI_RELATIVE_TO.BOTTOM_RIGHT);
//if (keyboard_check_pressed(vk_f1) && UI.exists("Panel6"))		UI.get("Panel6").setTabControlVisible(!UI.get("Panel6").getTabControlVisible());


//if (keyboard_check_pressed(vk_backspace)) UI.get("Toolbar").destroy();
//if (keyboard_check_pressed(vk_shift)) {
//	UI.get("testdrop").__dropdown_active = !UI.get("testdrop").__dropdown_active;
//}



//if (keyboard_check(vk_right) && UI.exists("progress"))	UI.get("progress").setValue(UI.get("progress").getValue()+5);
//if (keyboard_check(vk_left) && UI.exists("progress"))	UI.get("progress").setValue(UI.get("progress").getValue()-5);
//if (keyboard_check(vk_up) && UI.exists("progress2"))	UI.get("progress2").setValue(UI.get("progress2").getValue()+2);
//if (keyboard_check(vk_down) && UI.exists("progress2"))	UI.get("progress2").setValue(UI.get("progress2").getValue()-2);



//if (keyboard_check_pressed(vk_f3)) {
//	with (new UIPanel("modal", 0, 0, 500, 200, grey_panel, UI_RELATIVE_TO.MIDDLE_CENTER)) {
//		with (add(new UIText("tit1", 10, 10, "[fa_top][fa_center][c_red]Sup man"))) {
//			setBackgroundColor(#cccccc);
//		}
//		with (add(new UIText("tit2", 10, 10, "[fa_bottom][fa_right][c_lime]Yay", UI_RELATIVE_TO.BOTTOM_RIGHT))) {
//			setBackgroundColor(#cccccc);
//		}
//		with (add(new UIText("txt", 0, 0, "[c_black]Do you really wish to continue?", UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setBackgroundColor(#cccccc);
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message(self.__dimensions);
//			});
//		}
//		with (add(new UIButton("b1", -50, 40, 50, 30, "[fa_center][fa_middle]Yes", blue_button00, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message("Accepted");
//				self.getParent().destroy();
//			});
//		}
//		with (add(new UIButton("b2", 50, 40, 50, 30, "[fa_center][fa_middle]No", red_button00, UI_RELATIVE_TO.MIDDLE_CENTER))) {
//			setCallback(UI_EVENT.LEFT_CLICK, function() {
//				show_debug_message("Declined");
//				self.getParent().destroy();
//			});
//		}
//		setModal(true);
//	}
//}



//if  (keyboard_check_pressed(vk_enter)) {
//	with (new UIPanel("test1234", 40, 40, 400, 400, blue_panel)) {
//		addTab(2);
//		show_debug_message(getTabCount());
//		setTabSizeBehavior(UI_TAB_SIZE_BEHAVIOR.SPECIFIC);
//		setTabSpecificSize(100);
//		for (var _i=0; _i<3; _i++) {
//			setTabSprite(_i, red_button07);
//			setTabSpriteMouseover(_i, blue_button06);
//			setTabSpriteSelected(_i, yellow_button08);
//		}
//		setTabControlVisible(true);
//		setCloseButtonSprite(red_cross);
//		gotoTab(2);
//		//add(new UIText("t",50,150, "test1"), 0);
//		//add(new UIText("t",50,150, "test2"), 1);
//		//add(new UIText("t",50,150, "test3"), 2);
		
		
//		addTab(2);
//		setTabSprites(red_button07);
//		setTabSpritesMouseover(red_button06);
//		setTabSpritesSelected(red_button08);
//		setTabsTextFormat("[c_red]");
//		setTabsTextFormatMouseover("[c_yellow]");
//		setTabsTextFormatSelected("[c_black]");
//		setTabText(0, "Options");
//		setTabText(1, "Params");
//		setTabText(2, "Music");
		
//		var _chk = add(new UICheckbox("testc", 50, 100, "Test", red_checkmark, -1, true), 0);
//		_chk.setSpriteBase(grey_box).setInnerSpritesOffset({x: 9, y: 8});
		
//	}
//}
//if (UI.exists("test1234")) {
//	if (keyboard_check_pressed(vk_delete)) UI.get("test").removeTab(0);
//	if (keyboard_check_pressed(vk_home)) UI.get("test").addTab().setTabSprites(red_button07).setTabSpritesMouseover(red_button06).setTabSpritesSelected(red_button08);
//}

//if (keyboard_check_pressed(vk_f10)) UI.get("progress3").setValue(irandom_range(0,5));