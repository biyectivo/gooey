#region Helper Enums and Macros
	#macro UI_TEXT_RENDERER		scribble
	#macro UI_NUM_CALLBACKS		15
	#macro UI_LIBRARY_NAME		"UI2"
	#macro UI_LIBRARY_VERSION	"0.1"
	#macro UI_SCROLL_SPEED		20
	
	enum UI_MESSAGE_LEVEL {
		INFO,
		WARNING,
		ERROR,
		NOTICE
	}
	enum UI_EVENT {
		MOUSE_OVER,
		LEFT_CLICK,
		MIDDLE_CLICK,
		RIGHT_CLICK,
		LEFT_HOLD,
		MIDDLE_HOLD,
		RIGHT_HOLD,
		LEFT_RELEASE,
		MIDDLE_RELEASE,
		RIGHT_RELEASE,
		MOUSE_ENTER,		
		MOUSE_EXIT,
		MOUSE_WHEEL_UP,
		MOUSE_WHEEL_DOWN,
		
		VALUE_CHANGED
	}	
	enum UI_TYPE {
		PANEL,
		BUTTON,
		GROUP,
		TEXT,
		CHECKBOX,
		SLIDER,
		TEXTBOX,
		OPTION_GROUP,
		DROPDOWN,
		PROGRESSBAR,
		CANVAS
	}
	enum UI_RESIZE_DRAG {
		NONE,
		DRAG,
		RESIZE_NW,
		RESIZE_N,
		RESIZE_NE,
		RESIZE_W,
		RESIZE_E,
		RESIZE_SW,
		RESIZE_S,
		RESIZE_SE
	}	
	enum UI_RELATIVE_TO {
		TOP_LEFT,
		TOP_CENTER,
		TOP_RIGHT,
		MIDDLE_LEFT,
		MIDDLE_CENTER,
		MIDDLE_RIGHT,
		BOTTOM_LEFT,
		BOTTOM_CENTER,
		BOTTOM_RIGHT
	}
	enum UI_ORIENTATION {
		HORIZONTAL,
		VERTICAL
	}
	enum UI_PROGRESSBAR_RENDER_BEHAVIOR {
		REVEAL,
		STRETCH,
		REPEAT
	}
#endregion

#region Widgets

	#region UIPanel
	
		/// @constructor	UIPanel(_id, _x, _y, _width, _height, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Panel widget, the main container of the UI system
		/// @param			{String}			_id				The Panel's name, a unique string ID. If the specified name is taken, the panel will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Panel, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Panel, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Panel
		/// @param			{Real}				_height			The height of the Panel
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Panel
		/// @param			{Enum}				[_relative_to]	The position relative to which the Panel will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIPanel}							self
		function UIPanel(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.PANEL;			
				self.__draggable = true;
				self.__drag_bar_height = 32;
				self.__resizable = true;			
				self.__resize_border_width = 4;
				self.__title = "";
				self.__title_anchor = UI_RELATIVE_TO.TOP_CENTER;
				self.__close_button = noone;
				self.__close_button_sprite = noone;
				self.__close_button_anchor = UI_RELATIVE_TO.TOP_RIGHT;
				
				// Tabs Preparation
				self.__tabs = [[]];
				self.__current_tab = 0;
				
				self.__tab_group = {
					__vertical: false,
					__text_format: "[c_black]"
				}
				
				self.__tab_group_control = noone; // This is the UIGroup control for the tab buttons
								
				function __UITab(_sprite = grey_button02, _sprite_mouseover = blue_button04, _sprite_selected = red_button05) constructor {					
					self.text = "";
					self.text_mouseover = "";
					self.text_selected = "";					
					self.tab_index = 0;
					self.sprite_tab = _sprite;
					self.sprite_tab_mouseover = _sprite_mouseover;
					self.sprite_tab_selected = _sprite_selected;			
					self.image_tab = 0;
					self.image_tab_mouseover = 0;
					self.image_tab_selected = 0;
					return self;
				}
				
				// First tab data
				var _id_tab = new __UITab();
				self.__tab_data = [_id_tab];
				
				// Common widgets
				self.__common_widgets = [];
				self.__children = self.__tabs[self.__current_tab];	// self.__children is a pointer to the tabs array, which will be the one to be populated with widgets with add()
				
				// Modal
				self.__modal = false;
				self.__modal_color = c_black;
				self.__modal_alpha = 0.75;
				
			#endregion
			#region Setters/Getters		
			
				/// @method					getTitle()
				/// @desc					Returns the title of the Panel
				/// @return					{string} The title of the Panel
				self.getTitle = function()							{ return self.__title; }
			
				/// @method					setTitle(_title)
				/// @description			Sets the title of the Panel
				/// @param					{String} _title	The desired title
				/// @return					{UIPanel}	self
				self.setTitle = function(_title)					{ self.__title = _title; return self; }
			
				/// @method					getTitleAnchor()
				/// @description			Gets the anchor for the Panel title
				/// @return					{Enum}	The anchor for the Panel's title, according to UI_RELATIVE.
				self.getTitlelAnchor = function()					{ return self.__title_anchor; }
			
				/// @method					setTitleAnchor(_anchor)
				/// @description			Sets the anchor for the Panel title
				/// @param					{Enum}	_anchor	An anchor point for the Panel title, according to UI_RELATIVE.			
				/// @return					{UIPanel}	self
				self.setTitleAnchor = function(_anchor)				{ self.__title_anchor = _anchor; return self; }
			
				/// @method					getDragBarHeight()
				/// @description			Gets the height of the Panel's drag zone, from the top of the panel downward.			
				/// @return					{Real}	The height in pixels of the drag zone.
				self.getDragBarHeight = function()					{ return self.__drag_bar_height; }
			
				/// @method					setDragBarHeight(_height)
				/// @description			Sets the height of the Panel's drag zon, from the top of the panel downward.
				/// @param					{Real}	_height	The desired height in pixels
				/// @return					{UIPanel}	self
				self.setDragBarHeight = function(_height)			{ self.__drag_bar_height = _height; return self; }
			
				/// @method					getCloseButton()
				/// @description			Gets the close Button reference that is assigned to the Panel
				/// @return					{UIButton}	the Button reference
				self.getCloseButton = function() { return self.__close_button; }
			
				/// @method					setCloseButtonSprite(_button_sprite)
				/// @description			Sets a sprite for rendering the close button for the Panel. If `noone`, there will be no close button.
				/// @param					{Asset.GMSprite}	_button_sprite	The sprite to assign to the Panel close button, or `noone` to remove it
				/// @return					{UIPanel}	self
				self.setCloseButtonSprite = function(_button_sprite) { 
					if (self.__close_button_sprite == noone && _button_sprite != noone) { // Create button					
						self.__close_button_sprite = _button_sprite;
						self.__close_button = new UIButton(self.__ID+"_CloseButton", 0, 0, sprite_get_width(_button_sprite), sprite_get_height(_button_sprite), "", _button_sprite, self.__close_button_anchor);
						self.__close_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {						
							self.destroy(); // self is UIPanel here
						});
						self.add(self.__close_button, -1); // add to common
					}
					else if (self.__close_button_sprite != noone && _button_sprite != noone) { // Change sprite
						self.__close_button_sprite = _button_sprite;
						self.__close_button.setSprite(_button_sprite);
						self.__close_button.setDimensions(0, 0, sprite_get_width(_button_sprite), sprite_get_height(_button_sprite), "", _button_sprite, self.__close_button_anchor);
					}
					else if (self.__close_button_sprite != noone && _button_sprite == noone) { // Destroy button					
						self.remove(self.__close_button.__ID, -1);
						self.__close_button.destroy();
						self.__close_button = noone;
						self.__close_button_sprite = noone;					
					}				
					return self;
				}
				
				/// @method					getModal()
				/// @description			Gets whether this Panel is modal. <br>
				///							A modal Panel will get focus and disable all other widgets until it's destroyed. Only one Panel can be modal at any one time.
				/// @return					{Bool}	Whether this Panel is modal or not
				self.getModal = function()					{ return self.__modal; }
			
				/// @method					setModal(_modal)
				/// @description			Sets this Panel as modal.<br>
				///							A modal Panel will get focus and disable all other widgets until it's destroyed. Only one Panel can be modal at any one time.
				/// @param					{Bool}	_modal	whether to set this panel as modal
				/// @return					{UIPanel}	self
				self.setModal = function(_modal) {
					var _change = _modal != self.__modal;
					self.__modal = _modal;					
					if (_change) {
						if (self.__modal) {
							UI.setFocusedPanel(self.__ID);
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(false);
									if (UI.__panels[_i].__modal)	UI.__panels[_i].setModal(false);
								}
							}
						}
						else {
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(true);									
								}
							}
						}
					}
					return self;
				}
				
				/// @method					getModalOverlayColor()
				/// @description			Gets the color of the overlay drawn over non-modal Panels when this Panel is modal. If -1, it does not draw an overlay.
				/// @return					{Asset.GMColour}	the color to draw, or -1
				self.getModalOverlayColor = function()					{ return self.__modal_color; }
			
				/// @method					setModalOverlayColor(_color)
				/// @description			Sets the color of the overlay drawn over non-modal Panels when this Panel is modal. If -1, it does not draw an overlay.
				/// @param					{Asset.GMColour}	_color	the color to draw, or -1
				/// @return					{UIPanel}	self
				self.setModalOverlayColor = function(_color)			{ self.__modal_color = _color; return self;	}
					
				/// @method					getModalOverlayAlpha()
				/// @description			Gets the alpha of the overlay drawn over non-modal Panels when this Panel is modal.
				/// @return					{Real}	the alpha to draw the overlay with
				self.getModalOverlayAlpha = function()					{ return self.__modal_alpha; }
			
				/// @method					setModalOverlayAlpha(_alpha)
				/// @description			Sets the alpha of the overlay drawn over non-modal Panels when this Panel is modal.
				/// @param					{Real}	_alpha	the alpha to draw the overlay with
				/// @return					{UIPanel}	self
				self.setModalOverlayAlpha = function(_alpha)			{ self.__modal_alpha = _alpha; return self;	}
				
			#endregion	
			#region Setters/Getters - Tab Management
			
				/// @method				getRawTabText(_tab)
				/// @description		Gets the title text of the specified tab, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get title text from
				///	@return				{String}	The title text, without Scribble formatting tags
				self.getRawTabText = function(_tab)					{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text).get_text(); }
			
				/// @method				getTabText(_tab)
				/// @description		Gets the title text of the specified tab
				/// @param				{Real}	_tab	The tab to get title text from
				///	@return				{String}	The title text
				self.getTabText = function(_tab)					{ return self.__tab_data[_tab].text; }
				
				/// @method				setTabText(_tab, _text)
				/// @description		Sets the title text of the specified tab
				/// @param				{Real}		_tab	The tab to set title text
				/// @param				{String}	_text	The title text to set
				///	@return				{__UITabControl}	self
				self.setTabText = function(_tab, _text)				{ self.__tab_data[_tab].text = _text; return self; }
				
				/// @method				getRawTabTextMouseover(_tab)
				/// @description		Gets the title text of the specified tab when mouseovered, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get the mouseover title text from
				///	@return				{String}	The title text when mouseovered, without Scribble formatting tags
				self.getRawTabTextMouseover = function(_tab)		{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text_mouseover).get_text(); }
			
				/// @method				getTabTextMouseover(_tab)
				/// @description		Gets the title text of the specified tab when mouseovered
				/// @param				{Real}	_tab	The tab to get the mouseover title text from
				///	@return				{String}	The title text when mouseovered
				self.getTabTextMouseover = function(_tab)			{ return self.__tab_data[_tab].text_mouseover; }
				
				/// @method				setTabTextMouseover(_tab, _text)
				/// @description		Sets the title text of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to set mouseover title text from
				/// @param				{String}	_text	The title text to set when mouseovered
				///	@return				{__UITabControl}	self
				self.setTabTextMouseover = function(_tab, _text)	{ self.__tab_data[_tab].text_mouseover = _text; return self; }
				
				/// @method				getRawTabTextSelected(_tab)
				/// @description		Gets the title text of the specified tab when selected, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get the selected title text from
				///	@return				{String}	The title text when selected, without Scribble formatting tags
				self.getRawTabTextSelected = function(_tab)		{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text_selected).get_text(); }
			
				/// @method				getTabTextSelected(_tab)
				/// @description		Gets the title text of the specified tab when selected
				/// @param				{Real}	_tab	The tab to get the selected title text from
				///	@return				{String}	The title text when selected
				self.getTabTextSelected = function(_tab)			{ return self.__tab_data[_tab].text_selected; }
				
				/// @method				setTabTextSelected(_tab, _text)
				/// @description		Sets the title text of the specified tab when selected
				/// @param				{Real}		_tab	The tab to set selected title text from
				/// @param				{String}	_text	The title text to set when selected
				///	@return				{__UITabControl}	self
				self.setTabTextSelected = function(_tab, _text)	{ self.__tab_data[_tab].text_selected = _text; return self; }
				
				/// @method				getTabSprite(_tab)
				/// @description		Gets the sprite ID of the specified tab
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab
				self.getTabSprite = function(_tab)				{ return self.__tab_data[_tab].sprite_tab; }
			
				/// @method				setTabSprite(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{__UITabControl}	self
				self.setTabSprite = function(_tab, _sprite)			{ self.__tab_data[_tab].sprite_tab = _sprite; return self; }
			
				/// @method				getTabImage(_tab)
				/// @description		Gets the image index of the specified tab
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab
				self.getTabImage = function(_tab)				{ return self.__tab_data[_tab].image_tab; }
			
				/// @method				setTabImage(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{__UITabControl}	self
				self.setTabImage = function(_tab, _index)		{ self.__tab_data[_tab].image_tab = _index; return self; }
				
				/// @method				getTabSpriteMouseover(_tab)
				/// @description		Gets the sprite ID of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab when mouseovered
				self.getTabSpriteMouseover = function(_tab)			{ return self.__tab_data[_tab].sprite_tab_mouseover; }
			
				/// @method				setTabSpriteMouseover(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab when mouseovered
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{__UITabControl}	self
				self.setTabSpriteMouseover = function(_tab, _sprite)	{ self.__tab_data[_tab].sprite_tab_mouseover = _sprite; return self; }
			
				/// @method				getTabImageMouseover(_tab)
				/// @description		Gets the image index of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab when mouseovered
				self.getTabImageMouseover = function(_tab)			{ return self.__tab_data[_tab].image_tab_mouseover; }
			
				/// @method				setTabImageMouseover(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab when mouseovered
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{__UITabControl}	self
				self.setTabImageMouseover = function(_tab, _index)		{ self.__tab_data[_tab].image_tab_mouseover = _index; return self; }
				
				/// @method				getTabSpriteSelected(_tab)
				/// @description		Gets the sprite ID of the specified tab when selected
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab when selected
				self.getTabSpriteSelected = function(_tab)			{ return self.__tab_data[_tab].sprite_tab_selected; }
			
				/// @method				setTabSpriteSelected(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab when selected
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{__UITabControl}	self
				self.setTabSpriteSelected = function(_tab, _sprite)	{ self.__tab_data[_tab].sprite_tab_selected = _sprite; return self; }
			
				/// @method				getTabImageSelected(_tab)
				/// @description		Gets the image index of the specified tab when selected
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab when selected
				self.getTabImageSelected = function(_tab)			{ return self.__tab_data[_tab].image_tab_selected; }
			
				/// @method				setTabImageSelected(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab when selected
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{__UITabControl}	self
				self.setTabImageSelected = function(_tab, _index)		{ self.__tab_data[_tab].image_tab_selected = _index; return self; }
				
				/// @method				getSpriteTabBackground()
				/// @description		Gets the sprite ID of the tab header background
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab header background
				self.getSpriteTabBackground = function()			{ return self.__tab_group_control.getSprite(); }
			
				/// @method				setSpriteTabBackground(_sprite)
				/// @description		Sets the sprite to be rendered for the tab header background
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{__UITabControl}	self
				self.setSpriteTabBackground = function(_sprite)	{ 
					self.__tab_group_control.setSprite(_sprite);
					return self; 
				}
			
				/// @method				getImageTabBackground()
				/// @description		Gets the image index of the tab header background
				/// @return				{Real}		The image index of the tab header background
				self.getImageTabBackground = function()			{ return self.__tab_group_control.getImage(); }
			
				/// @method				setImageTabBackground(_index)
				/// @description		Sets the image index of the sprite to be rendered for the tab header background
				/// @param				{Real}				_index		The image index
				/// @return				{__UITabControl}	self
				self.setImageTabBackground = function(_index) { 
					self.__tab_group_control.setImage(_index);
					return self; 
				}	
								
				/// @method				getVerticalTabs()
				/// @description		Gets whether the tabs are being rendered vertically
				/// @return				{Bool}		whether the tabs are being rendered vertically
				self.getVerticalTabs = function()			{ return self.__tab_group.__vertical; }
			
				/// @method				setVerticalTabs(_vertical)
				/// @description		Sets whether the tabs are being rendered vertically
				/// @param				{Bool}				_vertical	whether to render tabs vertically
				/// @return				{__UITabControl}	self
				self.setVerticalTabs = function(_vertical)	{ 
					var _change = _vertical != self.__tab_group.__vertical;
					self.__tab_group.__vertical = _vertical;
					if (_change) {
						var _w = sprite_get_width(self.__tab_data[0].sprite_tab);
						var _h = sprite_get_height(self.__tab_data[0].sprite_tab);
						// Rearrange background
						if (self.__tab_group.__vertical) {
							self.__tab_group_control.setInheritWidth(false);
							self.__tab_group_control.setDimensions(,, _w, 1);							
							self.__tab_group_control.setInheritHeight(true);
						}
						else {
							self.__tab_group_control.setInheritHeight(false);
							self.__tab_group_control.setDimensions(,, 1, _h);
							self.__tab_group_control.setInheritWidth(true);							
						}
						
						// Rearrange buttons
						for (var _i=0, _n=array_length(self.__tab_group_control.__children); _i<_n; _i++) {
							if (self.__tab_group.__vertical) {
								var _x_button = 0;
								var _y_button = _i * _h;
							}
							else {
								var _x_button = _i * _w;
								var _y_button = 0;
							}
							self.__tab_group_control.__children[_i].setDimensions(_x_button, _y_button);
						}
					}
					return self;
				}
				
				/// @method				getTabControl()
				/// @description		Returns the tab control for further processing
				/// @return				{__UITabControl}	the tab control
				self.getTabControl = function()				{ return self.__tab_group_control; }
				
				/// @method				getTabControlVisible()
				/// @description		Returns whether the tab control is visible
				/// @return				{Bool}	whether the tab control is visible
				self.getTabControlVisible = function()		{ return self.__tab_group_control.getVisible(); }
				
				/// @method				setTabControlVisible(_visible)
				/// @description		Sets whether the tab control is visible
				/// @param				{Bool}	_visible	whether the tab control is visible
				/// @return				{UIPanel}	self
				self.setTabControlVisible = function(_visible)		{ self.__tab_group_control.setVisible(_visible); return self; }
								
				/// @method				getTabControlAlignment()
				/// @description		Gets the tab group control alignment (position relative to the Panel)
				/// @return				{Enum}	The tab group control alignment, according to `UI_RELATIVE_TO`.
				self.getTabControlAlignment = function() { return self.__tab_group_control.__relative_to; }
				
				/// @method				setTabControlAlignment(_relative_to)
				/// @description		Sets the tab group control alignment (position relative to the Panel)
				/// @param				{Enum}	_relative_to	The tab group control alignment, according to `UI_RELATIVE_TO`.
				/// @return				{UIPanel}	self
				self.setTabControlAlignment = function(_relative_to) {
					var _y = (_relative_to == UI_RELATIVE_TO.TOP_LEFT) || (_relative_to == UI_RELATIVE_TO.TOP_CENTER) || (_relative_to == UI_RELATIVE_TO.TOP_RIGHT) ? self.__drag_bar_height : 0;
					self.__tab_group_control.setDimensions(, _y,,,_relative_to); 
					self.__tab_group_control.__dimensions.calculateCoordinates();
					self.__tab_group_control.__updateChildrenPositions();
					return self;
				}
				
			#endregion	
			#region Methods
				
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					// Title
					if (self.__title != "")	{					
						var _s = UI_TEXT_RENDERER(self.__title);
					
						var _h = _s.get_height();
						var _title_x =	self.__title_anchor == UI_RELATIVE_TO.TOP_LEFT || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_LEFT || self.__title_anchor == UI_RELATIVE_TO.BOTTOM_LEFT ? _x : 
										((self.__title_anchor == UI_RELATIVE_TO.TOP_CENTER || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_CENTER || self.__title_anchor == UI_RELATIVE_TO.BOTTOM_CENTER ? _x+_width/2 : _x+_width));
						var _title_y =	self.__title_anchor == UI_RELATIVE_TO.TOP_LEFT || self.__title_anchor == UI_RELATIVE_TO.TOP_CENTER || self.__title_anchor == UI_RELATIVE_TO.TOP_RIGHT ? _y : 
										((self.__title_anchor == UI_RELATIVE_TO.MIDDLE_LEFT || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_CENTER || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_RIGHT ? _y+_height/2 : _y+_height));
						_s.draw(_title_x, _title_y);
					}
				}
			
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK])	UI.setFocusedPanel(self.__ID);
					__generalBuiltInBehaviors();
				}
			
				self.__drag = function() {										
					if (self.__draggable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.DRAG) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_SE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();					
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_NE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_SW) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_NW) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_N) {
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_S) {
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_W) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_E) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__updateChildrenPositions();
					}
				}
			
			#endregion
			#region Methods - Tab Management
				
				/// @method					addTab()
				/// @description			Adds a new tab at the end
				/// @return					{UIPanel}	self
				self.addTab = function()	{ 
					array_push(self.__tabs, []);
					var _id_tab = new __UITab();
					array_push(self.__tab_data, _id_tab);
					
					array_push(self.__cumulative_horizontal_scroll_offset, 0);
					array_push(self.__cumulative_vertical_scroll_offset, 0);
					
					var _n = self.getTabCount() - 1;
					_id_tab.text = "Tab "+string(_n); 
					_id_tab.text_mouseover = "Tab "+string(_n); 
					_id_tab.text_selected = "Tab "+string(_n); 
					
					// Add corresponding button
					
					var _panel_id = self.__ID;
					var _sprite_tab0 = self.getTabSprite(_n);
					var _w = sprite_get_width(_sprite_tab0);
					var _h = sprite_get_height(_sprite_tab0);
					self.setTabText(0, "Tab "+string(_n+1));
					if (self.__tab_group.__vertical) {
						var _x_button = 0;
						var _y_button = _n * _h;
					}
					else {
						var _x_button = _n * _w;
						var _y_button = 0;
					}
					var _button = self.__tab_group_control.add(new UIButton(_panel_id+"_TabControl_Group_TabButton"+string(_n), _x_button, _y_button, _w, _h, self.__tab_group.__text_format+self.getTabText(0), _sprite_tab0), -1);
					_button.setUserData("panel_id", _panel_id);
					_button.setUserData("tab_index", _n);
					_button.setSprite(self.__tab_data[_n].sprite_tab);
					_button.setImage(self.__tab_data[_n].image_tab);
					_button.setSpriteMouseover(self.__tab_data[_n].sprite_tab_mouseover);
					_button.setImageMouseover(self.__tab_data[_n].image_tab_mouseover);
					_button.setSpriteClick(self.__tab_data[_n].sprite_tab_mouseover);
					_button.setImageClick(self.__tab_data[_n].image_tab_mouseover);
					_button.setVisible(self.__tab_group_control.getVisible());
					with (_button) {
						setCallback(UI_EVENT.LEFT_CLICK, function() {
							UI.get(self.getUserData("panel_id")).gotoTab(self.getUserData("tab_index"));
						});
					}
					
					
					return self;
				}
				
				/// @method					removeTab([_tab = <current_tab>)
				/// @description			Removes the specified tab. Note, if there is only one tab left, you cannot remove it.
				/// @param					{Real}	[_tab]	The tab number to remove. If not specified, removes the current tab.
				/// @return					{UIPanel}	self
				self.removeTab = function(_tab = self.__current_tab)	{
					var _n = array_length(self.__tabs);
					if (_n > 1) {
						// Remove button and reconfigure the other buttons
						
						var _total = 0;					
						var _w = -1;
						for (var _i=0; _i<_n; _i++) {
							var _widget = self.__tab_group_control.__children[_i];
							var _tab_index = _widget.getUserData("tab_index");
							if (_tab_index == _tab) {
								_w = _widget;
							}
							else if (_tab_index > _tab) {
								var _x_button = (self.__tab_group.__vertical) ? 0 : _total;
								var _y_button = (self.__tab_group.__vertical) ? _total : 0;
								_widget.setDimensions(_x_button, _y_button);
								_widget.setUserData("tab_index", _i-1);
								_total += ((self.__tab_group.__vertical) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : sprite_get_width(self.__tab_data[_i].sprite_tab));
							}
							else {
								_total += ((self.__tab_group.__vertical) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : sprite_get_width(self.__tab_data[_i].sprite_tab));
							}
						}
						_w.destroy();
						
						// Remove from arrays
						var _curr_tab = self.__current_tab;
						array_delete(self.__tabs, _tab, 1);
						array_delete(self.__tab_data, _tab, 1);
						
						array_delete(self.__cumulative_horizontal_scroll_offset, _tab, 1);
						array_delete(self.__cumulative_vertical_scroll_offset, _tab, 1);
												
						var _m = array_length(self.__tabs);
						//if (_curr_tab == _m)	self.__current_tab = _m-1;
						if (_curr_tab == _m) {
							self.gotoTab(_m-1);
						}
						else {
							self.gotoTab(self.__current_tab);
						}
						//self.__children = self.__tabs[self.__current_tab];
						
					}
					return self;
				}
				
				/// @method					nextTab([_wrap = false])
				/// @description			Moves to the next tab
				/// @param					{Bool}	_wrap	If true, tab will return to the first one if called from the last tab. If false (default) and called from the last tab, it will remain in that tab.
				/// @return					{UIPanel}	self
				self.nextTab = function(_wrap = false)	{
					var _target;
					if (_wrap)	_target = (self.__current_tab + 1) % array_length(self.__tabs);
					else		_target = min(self.__current_tab + 1, array_length(self.__tabs)-1);
					/*if (_target != self.__current_tab)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__current_tab = _target;
					self.__children = self.__tabs[self.__current_tab];*/
					self.gotoTab(_target);
					return self;
				}
				
				/// @method					previousTab([_wrap = false])
				/// @description			Moves to the previous tab
				/// @param					{Bool}	_wrap	If true, tab will jump to the last one if called from the first tab. If false (default) and called from the first tab, it will remain in that tab.
				/// @return					{UIPanel}	self
				self.previousTab = function(_wrap = false)	{
					var _target;
					if (_wrap)	{
						_target = (self.__current_tab - 1);
						if (_target == -1)	 _target = array_length(self.__tabs)-1;
					}
					else		_target = max(_target - 1, 0);
					/*if (_target != self.__current_tab)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__current_tab = _target;
					self.__children = self.__tabs[self.__current_tab];*/
					self.gotoTab(_target);
					return self;
				}
				
								
				/// @method					gotoTab(_tab)
				/// @description			Moves to the specified tab
				/// @param					{Real}	_tab	The tab number.
				/// @return					{UIPanel}	self
				self.gotoTab = function(_tab)	{
					var _current = self.__current_tab;
					self.__current_tab = _tab;
					if (_current != self.__current_tab)		self.__tab_group_control.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__children = self.__tabs[self.__current_tab];
					for (var _i=0, _n=array_length(self.__tabs); _i<_n; _i++) {
						var _widget = self.__tab_group_control.__children[_i];
						if (_widget.getUserData("tab_index") == _tab) {
							_widget.setSprite(self.__tab_data[_i].sprite_tab_selected);
							_widget.setImage(self.__tab_data[_i].image_tab_selected);
						}
						else {
							_widget.setSprite(self.__tab_data[_i].sprite_tab);
							_widget.setImage(self.__tab_data[_i].image_tab);
						}
					}
					return self;
				}
				
				/// @method					getTabCount()
				/// @description			Gets the tab count for the widget. If this is a non-tabbed widget, it will return 0.
				/// @return					{Real}	The tab count for this Widget.
				self.getTabCount = function()	{
					if (self.__type == UI_TYPE.PANEL)	return array_length(self.__tabs);
					else								return 0;
				}
				
				/// @method					getTabTitle(_tab)
				/// @description			Gets the tab title of the specified tab
				/// @param					{Real}		_tab	The tab number
				/// @return					{String}	The tab title for _tab
				self.getTabTitle = function(_tab) {
					return self.getRawTabText(_tab);
				}
				
				/// @method				getCurrentTab()
				/// @description		Gets the index of the selected tab
				/// @return				{Real}	the index of the currently selected tab
				self.getCurrentTab = function()					{ return self.__current_tab; }
				
				
			#endregion
			
			// Register before tab controls so it has the final ID
			self.__register();
			
			#region Tab Control Initial Setup
			
				// Initial setup for tab 0
				var _panel_id = self.__ID;
				var _sprite_tab0 = self.getTabSprite(0);
				var _w = sprite_get_width(_sprite_tab0); // Start with something
				var _h = sprite_get_height(_sprite_tab0);
				if (self.__tab_group.__vertical) {
					self.__tab_group_control = self.add(new UIGroup(_panel_id+"_TabControl_Group", 0, self.__drag_bar_height, _w, 1, transparent, UI_RELATIVE_TO.TOP_LEFT), -1);
					self.__tab_group_control.setInheritHeight(true);
				}
				else {
					self.__tab_group_control = self.add(new UIGroup(_panel_id+"_TabControl_Group", 0, self.__drag_bar_height, 1, _h, transparent, UI_RELATIVE_TO.TOP_LEFT), -1);
					self.__tab_group_control.setInheritWidth(true);
				}
				self.__tab_group_control.setVisible(false);
				self.__tab_group_control.setClipsContent(true);
				self.setTabText(0, "Tab 1");				
				var _button = self.__tab_group_control.add(new UIButton(_panel_id+"_TabControl_Group_TabButton0", 0, 0, _w, _h, self.__tab_group.__text_format+self.getTabText(0), _sprite_tab0), -1);
				_button.setUserData("panel_id", _panel_id);
				_button.setUserData("tab_index", 0);
				_button.setSprite(self.__tab_data[0].sprite_tab_selected);
				_button.setImage(self.__tab_data[0].image_tab_selected);
				_button.setSpriteMouseover(self.__tab_data[0].sprite_tab_mouseover);
				_button.setImageMouseover(self.__tab_data[0].image_tab_mouseover);
				_button.setSpriteClick(self.__tab_data[0].sprite_tab_mouseover);
				_button.setImageClick(self.__tab_data[0].image_tab_mouseover);
				_button.setVisible(self.__tab_group_control.getVisible());
				with (_button) {
					setCallback(UI_EVENT.LEFT_CLICK, function() {	
						UI.get(self.getUserData("panel_id")).gotoTab(self.getUserData("tab_index"));
					});
				}
				
			#endregion
			
			self.setClipsContent(true);
			
			return self;
		}
	
	#endregion
	
	#region UIButton
	
		/// @constructor	UIButton(_id, _x, _y, _width, _height, _text, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Button widget, clickable UI widget that performs an action
		/// @param			{String}			_id				The Button's name, a unique string ID. If the specified name is taken, the Button will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Button, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Button, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Button
		/// @param			{Real}				_height			The height of the Button
		/// @param			{String}			_text			The text to display for the Button
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Button
		/// @param			{Enum}				[_relative_to]	The position relative to which the Button will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIButton}							self
		function UIButton(_id, _x, _y, _width, _height, _text, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.BUTTON;
				self.__text = _text;
				self.__text_mouseover = _text;
				self.__text_click = _text;
				self.__sprite_mouseover = _sprite;
				self.__sprite_click = _sprite;
				self.__image_mouseover = 0;
				self.__image_click = 0;			
			#endregion
			#region Setters/Getters
			
				// Note: set/get sprite, set/get image inherited from UIWidget.
			
				/// @method				getRawText()
				/// @description		Gets the text of the button, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawText = function()						{ return UI_TEXT_RENDERER(self.__text).get_text(); }
			
				/// @method				getText()
				/// @description		Gets the Scribble text string of the button.
				///	@return				{String}	The Scribble text string of the button.
				self.getText = function()							{ return self.__text; }
			
				/// @method				setText(_text)
				/// @description		Sets the Scribble text string of the button.
				/// @param				{String}	_text	The Scribble string to assign to the button.			
				/// @return				{UIButton}	self
				self.setText = function(_text)						{ self.__text = _text; return self; }
						
				/// @method				getRawTextMouseover()
				/// @description		Gets the text of the button when mouseovered, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the button when mouseovered.
				///	@return				{String}	The Scribble text string of the button when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the button when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the button when mouseovered.
				/// @return				{UIButton}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
			
				/// @method				getRawTextClick()
				/// @description		Gets the text of the button when clicked, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextClick = function()					{ return UI_TEXT_RENDERER(self.__text_click).get_text(); }
			
				/// @method				getTextClick()
				/// @description		Gets the Scribble text string of the button when clicked.
				///	@return				{String}	The Scribble text string of the button when clicked.
				self.getTextClick = function()						{ return self.__text_click; }
			
				/// @method				setTextClick(_text)
				/// @description		Sets the Scribble text string of the button when clicked.
				/// @param				{String}	_text	The Scribble string to assign to the button when clicked.
				/// @return				{UIButton}	self
				self.setTextClick = function(_text_click)			{ self.__text_click = _text_click; return self; }
									
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the button when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIButton}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getSpriteClick()
				/// @description		Gets the sprite ID of the button when clicked.			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when clicked
				self.getSpriteClick = function()					{ return self.__sprite_click; }
						
				/// @method				setSpriteClick(_sprite)
				/// @description		Sets the sprite to be rendered when clicked.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIButton}	self
				self.setSpriteClick = function(_sprite)				{ self.__sprite_click = _sprite; return self; }

				/// @method				getImageMouseover()
				/// @description		Gets the image index of the button when mouseovered.		
				/// @return				{Real}	The image index of the button when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the button when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UIButton}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getImageClick()
				/// @description		Gets the image index of the button when clicked.
				/// @return				{Real}	The image index of the button when clicked
				self.getImageClick = function()						{ return self.__image_click; }
			
				/// @method				setImageClick(_image)
				/// @description		Sets the image index of the button when clicked.
				/// @param				{Real}	_image	The image index
				/// @return				{UIButton}	self
				self.setImageClick = function(_image)				{ self.__image_click = _image; return self; }
			
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
				
					var _sprite = self.__sprite;
					var _image = self.__image;
					var _text = self.__text;
					if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
						_sprite =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__sprite_click : self.__sprite_mouseover;
						_image =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__image_click : self.__image_mouseover;
						_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
					}
					draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					
					var _x = _x + self.__dimensions.width * UI.getScale()/2;
					var _y = _y + self.__dimensions.height * UI.getScale()/2;
					var _scale = "[scale,"+string(UI.getScale())+"]";
				
					UI_TEXT_RENDERER(_scale+_text).draw(_x, _y);
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	
	#endregion
	
	#region UIGroup
	
		/// @constructor	UIGroup(_id, _x, _y, _width, _height, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Group widget, packs several widgets on a single, related group
		/// @param			{String}			_id				The Group's name, a unique string ID. If the specified name is taken, the Group will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Group, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Group, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Group
		/// @param			{Real}				_height			The height of the Group
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Group
		/// @param			{Enum}				[_relative_to]	The position relative to which the Group will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIGroup}							self
		function UIGroup(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.GROUP;	
			#endregion
			#region Setters/Getters
			
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);				
				}
				/*self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
				}*/
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion
	
	#region UIText
	
		/// @constructor	UIText(_id, _x, _y, _text, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Text widget, which renders a Scribble text to the screen
		/// @param			{String}			_id				The Text's name, a unique string ID. If the specified name is taken, the Text will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Text, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Text, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{String}			_text			The text to display for the Button
		/// @param			{Enum}				[_relative_to]	The position relative to which the Text will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIText}							self
		function UIText(_id, _x, _y, _text, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, -1, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.TEXT;
				self.__text = _text;
				self.__text_mouseover = _text;
				self.__text_click = _text;
				self.__border_color = -1;
				self.__background_color = -1;
				self.__max_width = 0;
			#endregion
			#region Setters/Getters
				/// @method				getRawText()
				/// @description		Gets the text of the UIText, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawText = function()						{ return UI_TEXT_RENDERER(self.__text).get_text(); }
			
				/// @method				getText()
				/// @description		Gets the Scribble text string of the UIText.
				///	@return				{String}	The Scribble text string of the button.
				self.getText = function()							{ return self.__text; }
			
				/// @method				setText(_text)
				/// @description		Sets the Scribble text string of the UIText.
				/// @param				{String}	_text	The Scribble string to assign to the UIText.			
				/// @return				{UIText}	self
				self.setText = function(_text)						{ self.__text = _text; return self; }
						
				/// @method				getRawTextMouseover()
				/// @description		Gets the text of the UIText when mouseovered, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the UIText when mouseovered.
				///	@return				{String}	The Scribble text string of the UIText when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the UIText when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the UIText when mouseovered.
				/// @return				{UIText}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
			
				/// @method				getRawTextClick()
				/// @description		Gets the text of the UIText when clicked, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextClick = function()					{ return UI_TEXT_RENDERER(self.__text_click).get_text(); }
			
				/// @method				getTextClick()
				/// @description		Gets the Scribble text string of the UIText when clicked.
				///	@return				{String}	The Scribble text string of the UIText when clicked.
				self.getTextClick = function()						{ return self.__text_click; }
			
				/// @method				setTextClick(_text)
				/// @description		Sets the Scribble text string of the UIText when clicked.
				/// @param				{String}	_text	The Scribble string to assign to the UIText when clicked.
				/// @return				{UIText}	self
				self.setTextClick = function(_text_click)			{ self.__text_click = _text_click; return self; }
			
				/// @method				getBorderColor()
				/// @description		Gets the border color of the text, or -1 if invisible
				///	@return				{Constant.Colour}	The border color or -1
				self.getBorderColor = function()					{ return self.__border_color; }
			
				/// @method				setBorderColor(_color)
				/// @description		Sets the border color of the text to a color, or unsets it if it's -1
				/// @param				{Constant.Color}	_color	The color constant, or -1
				/// @return				{UIText}	self
				self.setBorderColor = function(_color)			{ self.__border_color = _color; return self; }
			
				/// @method				getBackgroundColor()
				/// @description		Gets the background color of the text, or -1 if invisible
				///	@return				{Constant.Colour}	The background color or -1
				self.getBackgroundColor = function()				{ return self.__background_color; }
			
				/// @method				setBackgroundColor(_color)
				/// @description		Sets the background color of the text to a color, or unsets it if it's -1
				/// @param				{Constant.Color}	_color	The color constant, or -1
				/// @return				{UIText}	self
				self.setBackgroundColor = function(_color)			{ self.__background_color = _color; return self; }
			
				/// @method				getMaxWidth()
				/// @description		Gets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
				///	@return				{Real}	The max width, or 0 if unlimited
				self.getMaxWidth = function()				{ return self.__max_width; }
			
				/// @method				setMaxWidth(_max_width)
				/// @description		Sets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
				/// @param				{Real}	_max_width	The max width, or 0 if unlimited
				/// @return				{UIText}	self
				self.setMaxWidth = function(_max_width)			{ self.__max_width = _max_width; return self; }
			#endregion
			#region Methods
				self.__draw = function() {
					// Remember, this is the TOP-LEFT coordinate irrespective of Scribble alignment
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _text = self.__text;
					if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
						_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
					}
				
					var _scale = "[scale,"+string(UI.getScale())+"]";
				
					var _s = UI_TEXT_RENDERER(_scale+_text);					
					if (self.__max_width > 0)	_s.wrap(self.__max_width);
					
					self.setDimensions(,,_s.get_width(), _s.get_height());
				
					var _x1 = _s.get_left(_x);
					var _x2 = _s.get_right(_x);
					var _y1 = _s.get_top(_y);
					var _y2 = _s.get_bottom(_y);
					if (self.__background_color != -1)	draw_rectangle_color(_x1, _y1, _x2, _y2, self.__background_color, self.__background_color, self.__background_color, self.__background_color, false);
					if (self.__border_color != -1)		draw_rectangle_color(_x1, _y1, _x2, _y2, self.__border_color, self.__border_color, self.__border_color, self.__border_color, true);
								
					_s.draw(_x, _y);
					draw_circle_color(_x, _y, 2, c_red, c_red, false);
					draw_circle_color(_x+ _s.get_width()/2, _y+ _s.get_height()/2, 2, c_lime, c_lime, false);
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion
	
	#region UICheckbox
	
		/// @constructor	UICheckbox(_id, _x, _y, _text, _sprite, [_value=false], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Checkbox widget, clickable UI widget that stores a true/false state
		/// @param			{String}			_id				The Checkbox's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Checkbox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Checkbox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{String}			_text			The text to display for the Checkbox
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Checkbox
		/// @param			{Bool}				[_value]		The initial value of the Checkbox (default=false)
		/// @param			{Enum}				[_relative_to]	The position relative to which the Checkbox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UICheckbox}						self
		function UICheckbox(_id, _x, _y, _text, _sprite, _value=false, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.CHECKBOX;
				self.__text_false = _text;
				self.__text_true = _text;
				self.__text_mouseover = _text;
				self.__sprite_false = _sprite;
				self.__sprite_true = _sprite;
				self.__sprite_mouseover = _sprite;			
				self.__image_false = 0;
				self.__image_true = 1;
				self.__image_mouseover = -1;
				self.__value = _value;
			#endregion
			#region Setters/Getters			
				/// @method				getRawTextTrue()
				/// @description		Gets the text of the checkbox on the true state, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextTrue = function()					{ return UI_TEXT_RENDERER(self.__text_true).get_text(); }
			
				/// @method				getTextTrue()
				/// @description		Gets the Scribble text string of the checkbox on the true state.
				///	@return				{String}	The Scribble text string.
				self.getTextTrue = function()						{ return self.__text_true; }
			
				/// @method				setTextTrue(_text)
				/// @description		Sets the Scribble text string of the checkbox on the true state.
				/// @param				{String}	_text	The Scribble string to assign to the checbox for the true state.			
				/// @return				{UICheckbox}	self
				self.setTextTrue = function(_text)					{ self.__text_true = _text; return self; }
				
				/// @method				getRawTextFalse()
				/// @description		Gets the text of the checkbox on the false state, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextFalse = function()					{ return UI_TEXT_RENDERER(self.__text_false).get_text(); }
			
				/// @method				getTextFalse()
				/// @description		Gets the Scribble text string of the checkbox on the false state.
				///	@return				{String}	The Scribble text string.
				self.getTextFalse = function()						{ return self.__text_false; }
			
				/// @method				setTextFalse(_text)
				/// @description		Sets the Scribble text string of the checkbox on the false state.
				/// @param				{String}	_text	The Scribble string to assign to the checbox for the false state.			
				/// @return				{UICheckbox}	self
				self.setTextFalse = function(_text)					{ self.__text_false = _text; return self; }
				
				/// @method				getRawTextMouseover()
				/// @description		Gets the text of the checkbox when mouseovered, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the checkbox when mouseovered.
				///	@return				{String}	The Scribble text string of the button when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the checkbox when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the checkbox when mouseovered.
				/// @return				{UICheckbox}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
													
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the checkbox when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getImageMouseover()
				/// @description		Gets the image index of the checkbox when mouseovered.		
				/// @return				{Real}	The image index of the checkbox when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the checkbox when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getSpriteTrue()
				/// @description		Gets the sprite ID of the checkbox used for the true state.
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the true state.
				self.getSpriteTrue = function()				{ return self.__sprite_true; }
			
				/// @method				setSpriteTrue(_sprite)
				/// @description		Sets the sprite to be used for the true state.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteTrue = function(_sprite)			{ self.__sprite_true = _sprite; return self; }
			
				/// @method				getImageTrue()
				/// @description		Gets the image index of the checkbox used for the true state.
				/// @return				{Real}	The image index of the checkbox used for the true state.
				self.getImageTrue = function()					{ return self.__image_true; }
			
				/// @method				setImageTrue(_image)
				/// @description		Sets the image index of the checkbox used for the true state.
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageTrue = function(_image)			{ self.__image_true = _image; return self; }				
				
				/// @method				getSpriteFalse()
				/// @description		Gets the sprite ID of the checkbox used for the false state.	
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the false state.	
				self.getSpriteFalse = function()				{ return self.__sprite_false; }
			
				/// @method				setSpriteFalse(_sprite)
				/// @description		Sets the sprite to be used for the false state.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteFalse = function(_sprite)			{ self.__sprite_false = _sprite; return self; }
			
				/// @method				getImageFalse()
				/// @description		Gets the image index of the checkbox used for the false state.		
				/// @return				{Real}	The image index of the checkbox  used for the false state.	
				self.getImageFalse = function()					{ return self.__image_false; }
			
				/// @method				setImageFalse(_image)
				/// @description		Sets the image index of the checkbox used for the false state.	
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageFalse = function(_image)			{ self.__image_false = _image; return self; }
								
				/// @method				getValue()
				/// @description		Gets the value of the checkbox
				/// @return				{Bool}	the value of the checkbox
				self.getValue = function()						{ return self.__value; }
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the checkbox
				/// @param				{Bool}	_value	the value to set
				/// @return				{UICheckbox}	self
				self.setValue = function(_value) {
					var _change = _value != self.__value;
					self.__value = _value;
					if (_change)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					return self;
				}
				
				/// @method				toggle()
				/// @description		Toggles the value of the checkbox
				/// @return				{UICheckbox}	self
				self.toggle = function() { 					
					self.__value = !self.__value;
					self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					return self;
				}
								
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = (self.__value ? sprite_get_width(self.__sprite_true) : sprite_get_width(self.__sprite_false)) * UI.getScale();
					var _height = (self.__value ? sprite_get_height(self.__sprite_true) : sprite_get_height(self.__sprite_false)) * UI.getScale();
				
					var _sprite = self.__value ? self.__sprite_true : self.__sprite_false;
					var _image = self.__value ? self.__image_true : self.__image_false;
					var _text = self.__value ? self.__text_true : self.__text_false;
					
					// Deleted mouseover/click text/sprites
					
					draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
								
					var _x = _x + _width;
					var _y = _y + _height/2;
					
					var _scale = "[scale,"+string(UI.getScale())+"]";				
					var _s = UI_TEXT_RENDERER(_scale+_text);
					
					self.setDimensions(,,_width + _s.get_width(), _height + _s.get_height());
					_s.draw(_x, _y);
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						self.toggle();
					}
					
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UISlider
	
		/// @constructor	UISlider(_id, _x, _y, _length, _sprite, _sprite_handle, _value, _min_value, _max_value, [_orientation=UI_ORIENTATION.HORIZONTAL], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Slider widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id				The Slider's name, a unique string ID. If the specified name is taken, the Slider will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Slider, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Slider, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_length			The length of the Slider in pixels (this will be applied either horizontally or vertically depending on the `_orientation` parameter)
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Slider base
		/// @param			{Asset.GMSprite}	_sprite_handle	The sprite ID to use for rendering the Slider handle
		/// @param			{Real}				_value			The initial value of the Slider
		/// @param			{Real}				_min_value		The minimum value of the Slider
		/// @param			{Real}				_max_value		The maximum value of the Slider
		/// @param			{Enum}				[_orientation]	The orientation of the Slider, according to UI_ORIENTATION. By default: HORIZONTAL
		/// @param			{Enum}				[_relative_to]	The position relative to which the Slider will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UISlider}							self
		function UISlider(_id, _x, _y, _length, _sprite, _sprite_handle, _value, _min_value, _max_value, _orientation=UI_ORIENTATION.HORIZONTAL, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.SLIDER;
				self.__length = _length;
				self.__sprite_base = _sprite;
				self.__sprite_handle = _sprite_handle;
				self.__image_base = 0;
				self.__image_handle = 0;
				self.__value = _value;
				self.__min_value = _min_value;
				self.__max_value = _max_value;
				self.__small_change = 1;
				self.__scroll_change = 1;
				self.__big_change = 2;
				self.__show_min_max_text = true;
				self.__show_handle_text = true;
				self.__text_format = "";
				self.__orientation = _orientation;
				self.__handle_hold = false;
				self.__handle_anchor = UI_RELATIVE_TO.TOP_LEFT;
			#endregion
			#region Setters/Getters			
				
				/// @method				getLength()
				/// @description		Gets the length of the slider in pixels (this will be applied either horizontally or vertically depending on the orientation parameter)
				/// @return				{Real}	The length of the slider in pixels
				self.getLength = function()								{ return self.__length; }
			
				/// @method				setLength(_length)
				/// @description		Sets the length of the slider in pixels (this will be applied either horizontally or vertically depending on the orientation parameter)
				/// @param				{Real}	_length		The length of the slider in pixels
				/// @return				{UISlider}	self
				self.setLength = function(_length)						{ self.__length = _length; return self; }
				
				/// @method				getSpriteBase()
				/// @description		Gets the sprite ID used for the base of the slider.
				/// @return				{Asset.GMSprite}	The sprite ID used for the base of the slider.
				self.getSpriteBase = function()							{ return self.__sprite_base; }
			
				/// @method				setSpriteBase(_sprite)
				/// @description		Sets the sprite to be used for the base of the slider
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteBase = function(_sprite)					{ self.__sprite_base = _sprite; return self; }
			
				/// @method				getImageBase()
				/// @description		Gets the image index of the sprite used for the base of the slider.
				/// @return				{Real}	The image index of the sprite used for the base of the slider
				self.getImageBase = function()							{ return self.__image_base; }
			
				/// @method				setImageBase(_image)
				/// @description		Sets the image index of the sprite used for the base of the slider
				/// @param				{Real}	_image	The image index
				/// @return				{UISlider}	self
				self.setImageBase = function(_image)					{ self.__image_base = _image; return self; }				
				
				/// @method				getSpriteHandle()
				/// @description		Gets the sprite ID used for the handle of the slider.
				/// @return				{Asset.GMSprite}	The sprite ID used for the handle of the slider.
				self.getSpriteHandle = function()						{ return self.__sprite_handle; }
			
				/// @method				setSpriteHandle(_sprite)
				/// @description		Sets the sprite to be used for the handle of the slider
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteHandle = function(_sprite)				{ self.__sprite_handle = _sprite; return self; }
			
				/// @method				getImageHandle()
				/// @description		Gets the image index of the sprite used for the handle of the slider.
				/// @return				{Real}	The image index of the sprite used for the handle of the slider
				self.getImageHandle = function()						{ return self.__image_handle; }
			
				/// @method				setImageHandle(_image)
				/// @description		Sets the image index of the sprite used for the handle of the slider
				/// @param				{Real}	_image	The image index
				/// @return				{UISlider}	self
				self.setImageHandle = function(_image)					{ self.__image_handle = _image; return self; }		
												
				/// @method				getValue()
				/// @description		Gets the value of the slider
				/// @return				{Real}	the value of the slider
				self.getValue = function()								{ return self.__value; }
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the slider
				/// @param				{Real}	_value	the value to set
				/// @return				{UISlider}	self
				self.setValue = function(_value) { 
					if (clamp(_value, self.__min_value, self.__max_value) != self.__value)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__value = clamp(_value, self.__min_value, self.__max_value);
					return self;
				}
				
				/// @method				getMinValue()
				/// @description		Gets the minimum value of the slider
				/// @return				{Real}	the minimum value of the slider
				self.getMinValue = function()							{ return self.__min_value; }
				
				/// @method				setMinValue(_min_value)
				/// @description		Sets the minimum value of the slider
				/// @param				{Real}	_min_value	the value to set
				/// @return				{UISlider}	self
				self.setMinValue = function(_min_value)					{ self.__min_value = _min_value; return self; }
				
				/// @method				getMaxValue()
				/// @description		Gets the maximum value of the slider
				/// @return				{Real}	the maximum value of the slider
				self.getMaxValue = function()							{ return self.__max_value; }
				
				/// @method				setMaxValue(_max_value)
				/// @description		Sets the maximum value of the slider
				/// @param				{Real}	_max_value	the value to set
				/// @return				{UISlider}	self
				self.setMaxValue = function(_max_value)					{ self.__max_value = _max_value; return self; }
				
				/// @method				getSmallChange()
				/// @description		Gets the amount changed with a "small" change (dragging the handle)
				/// @return				{Real}	the small change amount
				self.getSmallChange = function()						{ return self.__small_change; }
				
				/// @method				setSmallChange(_max_value)
				/// @description		Sets the amount changed with a "small" change (dragging the handle)
				/// @param				{Real}	_amount	the small change amount
				/// @return				{UISlider}	self
				self.setSmallChange = function(_amount)					{ self.__small_change = _amount; return self; }
				
				/// @method				getScrollChange()
				/// @description		Gets the amount changed when scrolling with the mouse
				/// @return				{Real}	the mouse scroll change amount
				self.getScrollChange = function()						{ return self.__scroll_change; }
				
				/// @method				setScrollChange(_max_value)
				/// @description		Sets the amount changed when scrolling with the mouse
				/// @param				{Real}	_amount	the mouse scroll change amount
				/// @return				{UISlider}	self
				self.setScrollChange = function(_amount)					{ self.__scroll_change = _amount; return self; }
				
				/// @method				getBigChange()
				/// @description		Gets the amount changed with a "big" change (dragging the handle or scrolling with the mouse)
				/// @return				{Real}	the big change amount
				self.getBigChange = function()							{ return self.__big_change; }
				
				/// @method				setBigChange(_max_value)
				/// @description		Sets the amount changed with a "big" change (clicking on an empty area of the slider)
				/// @param				{Real}	_amount	the big change amount
				/// @return				{UISlider}	self
				self.setBigChange = function(_amount)					{ self.__big_change = _amount; return self; }
				
				/// @method				getOrientation()
				/// @description		Gets the orientation of the slider according to UI_ORIENTATION
				/// @return				{Enum}	the orientation of the slider
				self.getOrientation = function()						{ return self.__orientation; }
				
				/// @method				setOrientation(_orientation)
				/// @description		Sets the orientation of the slide
				/// @param				{Enum}	_orientation	the orientation according to UI_ORIENTATION
				/// @return				{UISlider}	self
				self.setOrientation = function(_orientation)			{ self.__orientation = _orientation; return self; }
				
				/// @method				getShowMinMaxText()
				/// @description		Gets whether the slider renders text for the min and max values
				/// @return				{Bool}	whether the slider renders min/max text
				self.getShowMinMaxText = function()						{ return self.__show_min_max_text; }
				
				/// @method				setShowMinMaxText(_value)
				/// @description		Sets whether the slider renders text for the min and max values
				/// @param				{Bool}	_value	whether the slider renders min/max text
				/// @return				{UISlider}	self
				self.setShowMinMaxText = function(_value)				{ self.__show_min_max_text = _value; return self; }
				
				/// @method				getShowHandleText()
				/// @description		Gets whether the slider renders text for the handle value
				/// @return				{Bool}	whether the slider renders renders text for the handle value
				self.getShowHandleText = function()						{ return self.__show_handle_text; }
				
				/// @method				setShowHandleText(_value)
				/// @description		Sets whether the slider renders text for the handle value
				/// @param				{Bool}	_value	whether the slider renders text for the handle value
				/// @return				{UISlider}	self
				self.setShowHandleText = function(_value)				{ self.__show_handle_text = _value; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the slider text
				/// @return				{String}	the Scribble text format used for the slider text
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the slider text
				/// @param				{Stirng}	_format	the Scribble text format used for the slider text
				/// @return				{UISlider}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
			#endregion
			#region Methods
				self.__getHandle = function() {
					var _proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
					var _handle_x, _handle_y;
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _width = self.__length * UI.getScale();
						var _height = max(sprite_get_height(self.__sprite_base), sprite_get_height(self.__sprite_handle)) * UI.getScale();
						var _handle_x = self.__dimensions.x + _width * _proportion - sprite_get_width(self.__sprite_handle)*UI.getScale()/2;
						var _handle_y = self.__dimensions.y;
					}
					else {
						var _width = max(sprite_get_width(self.__sprite_base), sprite_get_width(self.__sprite_handle)) * UI.getScale();
						var _height = self.__length * UI.getScale();
						var _handle_x = self.__dimensions.x;
						var _handle_y = self.__dimensions.y + _height * _proportion - sprite_get_height(self.__sprite_handle)*UI.getScale()/2;
					}
					return {x: _handle_x, y: _handle_y};
				}
				
				self.__draw = function() {
					// Clear holding state no matter what...
					if (self.__handle_hold && device_mouse_check_button_released(UI.getMouseDevice(), mb_left)) {
						var _m_x = device_mouse_x(UI.getMouseDevice());
						var _m_y = device_mouse_y(UI.getMouseDevice());
						if (self.__orientation == UI_ORIENTATION.HORIZONTAL)  {
							if (_m_x > self.__dimensions.x + self.__dimensions.width)	self.setValue(self.__max_value);
							if (_m_x < self.__dimensions.x)	self.setValue(self.__min_value);
						}
						else {
							if (_m_y > self.__dimensions.y + self.__dimensions.height)	self.setValue(self.__max_value);
							if (_m_y < self.__dimensions.y)	self.setValue(self.__min_value);
						}
						self.__handle_hold = false;
					}
										
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
					
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _width = self.__length * UI.getScale();
						var _height = max(sprite_get_height(self.__sprite_base), sprite_get_height(self.__sprite_handle)) * UI.getScale();
						var _width_base = _width;
						var _height_base = sprite_get_height(self.__sprite_base) * UI.getScale();						
					}
					else {
						var _width = max(sprite_get_width(self.__sprite_base), sprite_get_width(self.__sprite_handle)) * UI.getScale();
						var _height = self.__length * UI.getScale();
						var _width_base = sprite_get_width(self.__sprite_base) * UI.getScale();
						var _height_base = _height;						
					}
					var _handle = self.__getHandle();
					
					draw_sprite_stretched_ext(self.__sprite_base, self.__image_base, _x, _y, _width_base, _height_base, self.__image_blend, self.__image_alpha);
					draw_sprite_ext(self.__sprite_handle, self.__image_handle, _handle.x, _handle.y, 1, 1, 0, self.__image_blend, self.__image_alpha);

					self.setDimensions(,, _width, _height);
					
					if (self.__show_min_max_text) {
						var _smin = UI_TEXT_RENDERER(self.__text_format + string(self.__min_value));
						var _smax = UI_TEXT_RENDERER(self.__text_format + string(self.__max_value));												
						if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
							_smin.draw(_x - _smin.get_width(), _y);
							_smax.draw(_x + _width, _y);
						}
						else {
							_smin.draw(_x, _y - _smin.get_height());
							_smax.draw(_x, _y + _height);
						}
					}
					
					if (self.__show_handle_text) {
						var _stxt = UI_TEXT_RENDERER(self.__text_format + string(self.__value));
						if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
							_stxt.draw(_handle.x + sprite_get_width(self.__sprite_handle)/2, _handle.y - _stxt.get_height());
						}
						else {
							_stxt.draw(_handle.x - _stxt.get_width(), _handle.y + sprite_get_height(self.__sprite_handle)/2);
						}
					}
										
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					
					// Check if click is outside handle
					var _m_x = device_mouse_x(UI.getMouseDevice());
					var _m_y = device_mouse_y(UI.getMouseDevice());
					var _handle = self.__getHandle();
					var _within_handle = point_in_rectangle(_m_x, _m_y, _handle.x, _handle.y, _handle.x + sprite_get_width(self.__sprite_handle) * UI.getScale(), _handle.y + sprite_get_height(self.__sprite_handle));
					
					// Check if before or after handle
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _before = _m_x < _handle.x + sprite_get_width(self.__sprite_handle)/2;
					}
					else {
						var _before = _m_y < _handle.y + sprite_get_height(self.__sprite_handle)/2;
					}
					
					if (!_within_handle && self.__events_fired[UI_EVENT.LEFT_CLICK]) {						
						self.setValue(self.__value + (_before ? -1 : 1) * self.__big_change);
					}
					else if (_within_handle && !self.__handle_hold && self.__events_fired[UI_EVENT.LEFT_HOLD]) {
						self.__handle_hold = true;
					}					
					else if (self.__handle_hold) {
						var _min_x = self.__dimensions.x;
						var _max_x = self.__dimensions.x + self.__dimensions.width;
						var _min_y = self.__dimensions.y;
						var _max_y = self.__dimensions.y + self.__dimensions.height;
						var _proportion = self.__orientation == UI_ORIENTATION.HORIZONTAL ? (_m_x + sprite_get_width(self.__sprite_handle) * UI.getScale()/2 - _min_x)/(_max_x - _min_x) : (_m_y + sprite_get_height(self.__sprite_handle) * UI.getScale()/2 - _min_y)/(_max_y - _min_y);
						self.setValue( round( (_proportion * (self.__max_value - self.__min_value))/self.__small_change ) * self.__small_change );
					}
					else if (self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP]) {
						self.setValue(self.__value - self.__scroll_change);
					}
					else if (self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN]) {
						self.setValue(self.__value + self.__scroll_change);
					}
					
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UITextBox
	
		/// @constructor	UITextBox(_id, _x, _y, _width, _height, _sprite, _max_chars, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A TextBox widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id				The TextBox's name, a unique string ID. If the specified name is taken, the TextBox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the TextBox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the TextBox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the TextBox
		/// @param			{Real}				_height			The height of the TextBox
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the TextBox
		/// @param			{Real}				_max_chars		The maximum number of characters for the TextBox
		/// @param			{Enum}				[_relative_to]	The position relative to which the TextBox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UITextBox}							self
		function UITextBox(_id, _x, _y, _width, _height, _sprite, _max_length, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.TEXTBOX;
				self.__text = "";
				self.__placeholder_text = "";
				self.__max_chars = 99999999;
				self.__mask_text = false;
				self.__mask_char = "*";
				self.__multiline = false;
				self.__cursor_pos = -1;
				self.__currently_editing = false;
				self.__read_only = false;
				self.__allow_uppercase_letters = true;
				self.__allow_lowercase_letters = true;
				self.__allow_spaces = true;
				self.__allow_digits = true;
				self.__allow_symbols = true;
				self.__symbols_allowed = "";
				self.__allow_cursor_mouse = true;
				self.__allow_cursor_keyboard = false;
				self.__text_anchor = UI_RELATIVE_TO.TOP_LEFT;
				self.__text_format = "";
				self.__text_margin = 2;
				
				self.__display_starting_char = 0;
				self.__surface_id = -1;
				
				// Adjust width/height to consider margin
				self.__dimensions.set(,, self.__dimensions.width + 2*self.__text_margin, self.__dimensions.height + 2*self.__text_margin);
			#endregion
			#region Setters/Getters			
				
				/// @method				getText()
				/// @description		Gets the text of the textbox
				/// @return				{String}	The text of the textbox
				self.getText = function()								{ return self.__text; }
			
				/// @method				setText(_text)
				/// @description		Sets the text of the textbox. If set to read only, this will have no effect.
				/// @param				{String}	__text	The text to set
				/// @return				{UITextBox}	self
				self.setText = function(_text) {
					if (!self.__read_only) {
						var _change = _text != self.__text;
						if (_change) {						
							self.__text = self.__max_chars == 99999999 ? _text : string_copy(_text, 1, self.__max_chars);							
							self.__callbacks[UI_EVENT.VALUE_CHANGED]();
						}
						self.__processCursor(_change);
					}
					return self;
				}
				
				/// @method				getPlaceholderText()
				/// @description		Gets the placeholder text of the textbox (text that is shown when the textbox is empty)
				/// @return				{String}	The placeholder text of the textbox
				self.getPlaceholderText = function()					{ return self.__placeholder_text; }
			
				/// @method				setPlaceholderText(_text)
				/// @description		Sets the placeholder text of the textbox (text that is shown when the textbox is empty)
				/// @param				{String}	__text	The placeholder text to set
				/// @return				{UITextBox}	self
				self.setPlaceholderText = function(_text)				{ self.__placeholder_text = _text; return self; }
				
				/// @method				getMaxChars()
				/// @description		Gets the maximum character limit for the textbox. If 0, the textbox has no limit.
				/// @return				{Real}	The character limit for the textbox
				self.getMaxChars = function()							{ return self.__max_chars; }
			
				/// @method				setMaxChars(_max_chars)
				/// @description		Sets the maximum character limit for the textbox. If 0, the textbox has no limit.
				/// @param				{Real}	_max_chars	The character limit to set
				/// @return				{UITextBox}	self
				self.setMaxChars = function(_max_chars)	{
					self.__max_chars = _max_chars;
					if (_max_chars >  0 && string_length(self.__text) > _max_chars)	self.__text = string_copy(self.__text, 1, _max_chars);
					return self;
				}
				
				/// @method				getMaskText()
				/// @description		Gets whether text is masked using a masking character
				/// @return				{Bool}	Whether the text is masked or not
				self.getMaskText = function()							{ return self.__mask_text; }
				
				/// @method				setMaskText(_mask_text)
				/// @description		Sets whether text is masked using a masking character
				/// @param				{Bool}	_mask_text	Whether the text is masked or not
				/// @return				{UITextBox}	self
				self.setMaskText = function(_mask_text)					{ self.__mask_text = _mask_text; return self; }
				
				/// @method				getMaskChar()
				/// @description		Gets the character used to mask text
				/// @return				{String}	The character used to mask
				self.getMaskChar = function()							{ return self.__mask_char; }
				
				/// @method				setMaskChar(_mask_char)
				/// @description		Sets the character used to mask text
				/// @param				{String}	_mask_char	The character to use to mask
				/// @return				{UITextBox}	self
				self.setMaskChar = function(_mask_char)					{ self.__mask_char = _mask_char; return self; }
				
				/// @method				getMultiline()
				/// @description		Returns whether the textbox is multi-line or not.
				/// @return				{Bool}	Whether the textbox is multiline or not
				self.getMultiline = function()							{ return self.__multiline; }
				
				/// @method				setMultiline(_multiline)
				/// @description		Sets whether the textbox is multi-line or not.
				/// @param				{Bool}	_multiline	Whether to set the textbox to multiline or not
				/// @return				{UITextBox}	self
				self.setMultiline = function(_multiline)					{ self.__multiline = _multiline; return self; }
				
				/// @method				getCursorPos()
				/// @description		Returns the cursor position (in characters)
				/// @return				{Real}	the cursor position
				self.getCursorPos = function()							{ return self.__cursor_pos; }
				
				/// @method				setCursorPos(_pos)
				/// @description		Sets the cursor position (in characters)
				/// @param				{Real}	_pos	The cursor position
				/// @return				{UITextBox}	self
				self.setCursorPos = function(_pos)						{ self.__cursor_pos = _pos; return self; }
				
				/// @method				getCurrentlyEditing()
				/// @description		Returns whether the textbox is being edited or not
				/// @return				{Bool}	Whether the textbox is being edited or not
				self.getCurrentlyEditing = function()					{ return UI.__textbox_editing_ref == self; }
				
				/// @method				setCurrentlyEditing(_edit)
				/// @description		Sets whether the textbox is being edited or not. Will only set if the textbox is not set to read only.
				/// @param				{Bool}	_edit	Whether the textbox is being edited
				/// @return				{UITextBox}	self
				self.setCurrentlyEditing = function(_edit) {
					if (!self.__read_only && _edit) {
						UI.__textbox_editing_ref = self;
					}
					return self;
				}
				
				/// @method				getReadOnly()
				/// @description		Returns whether the textbox is read-only or not
				/// @return				{Bool}	Whether the textbox is read-only or not
				self.getReadOnly = function()							{ return self.__read_only; }
				
				/// @method				setReadOnly(_read_only)
				/// @description		Sets whether the textbox is read-only or not
				/// @param				{Bool}	_read_only	Whether the textbox is the textbox is read-only
				/// @return				{UITextBox}	self
				self.setReadOnly = function(_read_only)					{ self.__read_only = _read_only; return self; }
				
				/// @method				getAllowUppercaseLetters()
				/// @description		Returns whether uppercase letters are allowed in the textbox
				/// @return				{Bool}	Whether uppercase letters are allowed
				self.getAllowUppercaseLetters = function()				{ return self.__allow_uppercase_letters; }
				
				/// @method				setAllowUppercaseLetters(_allow_uppercase_letters)
				/// @description		Sets whether uppercase letters are allowed in the textbox
				/// @param				{Bool}	_allow_uppercase_letters	Whether uppercase letters are allowed
				/// @return				{UITextBox}	self
				self.setAllowUppercaseLetters = function(_allow_uppercase_letters)			{ self.__allow_uppercase_letters = _allow_uppercase_letters; return self; }
				
				/// @method				getAllowLowercaseLetters()
				/// @description		Returns whether lowercase letters are allowed in the textbox
				/// @return				{Bool}	Whether lowercase letters are allowed
				self.getAllowLowercaseLetters = function()				{ return self.__allow_lowercase_letters; }
				
				/// @method				setAllowLowercaseLetters(_allow_lowercase_letters)
				/// @description		Sets whether lowercase letters are allowed in the textbox
				/// @param				{Bool}	_allow_lowercase_letters	Whether lowercase letters are allowed
				/// @return				{UITextBox}	self
				self.setAllowLowercaseLetters = function(_allow_lowercase_letters)			{ self.__allow_lowercase_letters = _allow_lowercase_letters; return self; }
				
				/// @method				getAllowSpaces()
				/// @description		Returns whether spaces are allowed in the textbox
				/// @return				{Bool}	Whether spaces are allowed
				self.getAllowSpaces = function()						{ return self.__allow_spaces; }
				
				/// @method				setAllowSpaces(_allow_spaces)
				/// @description		Sets whether spaces are allowed in the textbox
				/// @param				{Bool}	_allow_spaces	Whether spaces are allowed
				/// @return				{UITextBox}	self
				self.setAllowSpaces = function(_allow_spaces)			{ self.__allow_spaces = _allow_spaces; return self; }
				
				/// @method				getAllowDigits()
				/// @description		Returns whether digits are allowed in the textbox
				/// @return				{Bool}	Whether digits are allowed
				self.getAllowDigits = function()						{ return self.__allow_digits; }
				
				/// @method				setAllowDigits(_allow_digits)
				/// @description		Sets whether digits are allowed in the textbox
				/// @param				{Bool}	_allow_digits	Whether digits are allowed
				/// @return				{UITextBox}	self
				self.setAllowDigits = function(_allow_digits)			{ self.__allow_digits = _allow_digits; return self; }
				
				/// @method				getAllowSymbols()
				/// @description		Returns whether symbols are allowed in the textbox
				/// @return				{Bool}	Whether symbols are allowed
				self.getAllowSymbols = function()						{ return self.__allow_symbols; }
				
				/// @method				setAllowSymbols(_allow_symbols)
				/// @description		Sets whether symbols are allowed in the textbox. The specific symbols allowed can be set with the setSymbolsAllowed method.
				/// @param				{Bool}	_allow_symbols	Whether symbols are allowed
				/// @return				{UITextBox}	self
				self.setAllowSymbols = function(_allow_symbols)			{ self.__allow_symbols = _allow_symbols; return self; }
				
				/// @method				getAllowCursorMouse()
				/// @description		Returns whether mouse cursor navigation is allowed
				/// @return				{Bool}	Whether mouse cursor navigation is allowed
				self.getAllowCursorMouse = function()					{ return self.__allow_cursor_mouse; }
				
				/// @method				setAllowCursorMouse(_allow_cursor_mouse)
				/// @description		Sets whether mouse cursor navigation is allowed
				/// @param				{Bool}	_allow_cursor_mouse	Whether mouse cursor navigation is allowed
				/// @return				{UITextBox}	self
				self.setAllowCursorMouse = function(_allow_cursor_mouse)	{ self.__allow_cursor_mouse = _allow_cursor_mouse; return self; }
				
				/// @method				getAllowCursorKeyboard()
				/// @description		Returns whether keyboard cursor navigation is allowed
				/// @return				{Bool}	Whether keyboard cursor navigation is allowed
				self.getAllowCursorKeyboard = function()					{ return self.__allow_cursor_keyboard; }
				
				/// @method				setAllowCursorKeyboard(_allow_cursor_keyboard)
				/// @description		Sets whether keyboard cursor navigation is allowed
				/// @param				{Bool}	_allow_cursor_keyboard	Whether keyboard cursor navigation is allowed
				/// @return				{UITextBox}	self
				self.setAllowCursorKeyboard = function(_allow_cursor_keyboard)	{ self.__allow_cursor_keyboard = _allow_cursor_keyboard; return self; }
				
				/// @method				getSymbolsAllowed()
				/// @description		Returns the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
				/// @return				{String}	The list of allowed symbols
				self.getSymbolsAllowed = function()					{ return self.__symbols_allowed; }
				
				/// @method				setSymbolsAllowed(_symbols)
				/// @description		Sets the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
				/// @param				{String}	_symbols	The list of allowed symbols
				/// @return				{UITextBox}	self
				self.setSymbolsAllowed = function(_symbols)	{ self.__symbols_allowed = _symbols; return self; }
				
				/// @method				getTextAnchor()
				/// @description		Returns the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
				/// @return				{Enum}	The text anchor
				self.getTextAnchor = function()					{ return self.__text_anchor; }
				
				/// @method				setTextAnchor(_anchor)
				/// @description		Sets the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
				/// @param				{Enum}	_anchor		The desired text anchor
				/// @return				{UITextBox}	self
				self.setTextAnchor = function(_anchor)	{ self.__text_anchor = _anchor; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the textbox
				/// @return				{String}	the Scribble text format used for the textbox
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the textbox
				/// @param				{String}	_format	the Scribble text format used for the textbox
				/// @return				{UITextBox}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
				/// @method				getTextMargin()
				/// @description		Gets the text margin for the text inside the textbox
				/// @return				{Real}	the margin for the text inside the textbox
				self.getTextMargin = function()							{ return self.__text_margin; }
				
				/// @method				setTextMargin(_margin)
				/// @description		Sets the text margin for the text inside the textbox
				/// @param				{Real}	_margin		the margin for the text inside the textbox
				/// @return				{UITextBox}	self
				self.setTextMargin = function(_margin)					{ self.__text_margin = _margin; return self; }
				
			#endregion
			#region Methods
				
				/// @method				clearText()
				/// @description		clears the TextBox text
				/// @return				{UITextBox}	self
				self.clearText= function() {
					self.setText("");
					self.__cursor_pos = -1;
				}
				
				self.__processCursor = function(_text_change) {
					if (_text_change) {
						if (keyboard_lastkey == vk_backspace)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : max(0, self.__cursor_pos-1);
						else if (keyboard_lastkey == vk_delete)	keyboard_lastkey = vk_nokey;
						else if (keyboard_lastkey != vk_delete)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos+1;
					}
					else {									
						if (keyboard_lastkey == vk_home)		self.__cursor_pos = 0;
						else if (keyboard_lastkey == vk_end)	self.__cursor_pos = -1;
						else if (keyboard_lastkey == vk_left) {
							var _n = string_length(self.__text);
							if (keyboard_check(vk_control) && self.__cursor_pos != 0)	{
								do {
									self.__cursor_pos = self.__cursor_pos == -1 ? _n-1 : self.__cursor_pos - 1;
								}
								until (self.__cursor_pos == 0 || string_char_at(self.__text, self.__cursor_pos) == " ");
								
							}
							else {
								self.__cursor_pos = (self.__cursor_pos == -1 ? _n-1 : max(self.__cursor_pos-1, 0));
							}
							keyboard_lastkey = vk_nokey;
						}
						else if (keyboard_lastkey == vk_right) {
							var _n = string_length(self.__text);
							if (keyboard_check(vk_control) && self.__cursor_pos != -1)	{
								do {
									self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos + 1;
									if (self.__cursor_pos == _n) self.__cursor_pos = -1;
								}
								until (self.__cursor_pos == -1 || string_char_at(self.__text, self.__cursor_pos) == " ");								
							}
							else {
								if (self.__cursor_pos >= 0) self.__cursor_pos = ( self.__cursor_pos == _n-1 ? -1 : self.__cursor_pos+1 );						
							}
							keyboard_lastkey = vk_nokey;
						}
					}
				}
				
				self.__draw = function() {
					// Clean the click command
					if ((keyboard_check_pressed(vk_enter) && !self.__multiline) && UI.__textbox_editing_ref == self && !self.__read_only) {
						UI.__textbox_editing_ref = noone;
						self.__cursor_pos = -1;
						keyboard_string = "";
					}
					
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();					
					var _height = self.__dimensions.height * UI.getScale();
															
					var _text_to_display = (self.__text == "" && UI.__textbox_editing_ref != self) ? self.__placeholder_text : (self.__mask_text ? string_repeat(self.__mask_char, string_length(self.__text)) : self.__text);
					var _cursor = (UI.__textbox_editing_ref == self ? "[blink][c_gray]|[/blink]"+self.getTextFormat() : "");
					var _text_with_cursor = self.__cursor_pos == -1 ? _text_to_display + _cursor : string_copy(_text_to_display, 1, self.__cursor_pos)+_cursor+string_copy(_text_to_display, self.__cursor_pos+1, string_length(_text_to_display));
					
					var _n = max(1, string_length(_text_to_display));
					var _avg_width = UI_TEXT_RENDERER(self.__text_format + "e").get_width();
					var _letter_height = UI_TEXT_RENDERER(self.__text_format + "|").get_height();
					var _s = UI_TEXT_RENDERER(self.__text_format + _text_with_cursor);
										
					// Fix width
					var _offset = max(0, _s.get_width() - _width);
					
					if (self.__multiline) {
						_s.wrap(_width - 2*self.__text_margin);						
					}
					else {						
						_height = _letter_height + 2*self.__text_margin;
						self.__dimensions.height = _height * UI.getScale();
					}
					
					if (_offset > 0 && self.__cursor_pos != -1) {
						var _test = UI_TEXT_RENDERER(string_copy(_text_to_display, 1, self.__cursor_pos)).get_width();
						var _cursor_left_of_textbox = (_test < _offset);
						while (_cursor_left_of_textbox) {
							_offset -= 2*_avg_width;
							_cursor_left_of_textbox = (_test < _offset);
						}
					}
					
					
					draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					
					if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(_width, _height);
					surface_set_target(self.__surface_id);
					draw_clear_alpha(c_black, 0);
					_s.draw(self.__text_margin - _offset, self.__text_margin);
					surface_reset_target();
					draw_surface(self.__surface_id, _x, _y);					
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK] && UI.__textbox_editing_ref != self)  {
						if (UI.__textbox_editing_ref != noone)	UI.__textbox_editing_ref.__cursor_pos = -1;
						keyboard_string = self.__cursor_pos == -1 ? self.__text : string_copy(self.__text, 1, self.__cursor_pos);
						UI.__textbox_editing_ref = self;
						self.__callbacks[UI_EVENT.LEFT_CLICK]();
					}
					
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UIOptionGroup
	
		/// @constructor	UIOptionGroup(_id, _x, _y, _option_array, _sprite, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	An option group widget, clickable UI widget that lets the user select from a list of values.
		/// @param			{String}			_id				The Checkbox's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Checkbox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Checkbox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Array<String>}		_option_array	An array with at least one string that contains the text for each of the options
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the option group
		/// @param			{Real}				[_initial_idx]	The initial selected index of the Option group (default=0, the first option)
		/// @param			{Enum}				[_relative_to]	The position relative to which the Checkbox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIOptionGroup}						self
		function UIOptionGroup(_id, _x, _y, _option_array, _sprite, _initial_idx=-1, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.OPTION_GROUP;
				self.__option_array_unselected = _option_array;
				self.__option_array_selected = _option_array;
				self.__option_array_mouseover = _option_array;
				self.__sprite_unselected = _sprite;
				self.__sprite_selected = _sprite;
				self.__sprite_mouseover = _sprite;			
				self.__image_unselected = 0;
				self.__image_selected = 1;
				self.__image_mouseover = -1;
				self.__index = _initial_idx;
				self.__vertical = true;
				self.__spacing = 20;
				
				self.__option_array_dimensions = [];
			#endregion
			#region Setters/Getters			
				/// @method				getRawOptionArrayUnselected()
				/// @description		Gets the options text array of the group, for the unselected state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the unselected state, without Scribble formatting tags
				self.getRawOptionArrayUnselected = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_unselected); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_unselected[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArrayUnselected()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the unselected state
				self.getOptionArrayUnselected = function()						{ return self.__option_array_unselected; }
			
				/// @method				setOptionArrayUnselected(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArrayUnselected = function(_option_array)			{ self.__option_array_unselected = _option_array; return self; }
				
				/// @method				getRawOptionArraySelected()
				/// @description		Gets the options text array of the group, for the selected state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the selected state, without Scribble formatting tags
				self.getRawOptionArraySelected = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_selected); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_selected[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArraySelected()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the selected state
				self.getOptionArraySelected = function()						{ return self.__option_array_selected; }
			
				/// @method				setOptionArraySelected(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArraySelected = function(_option_array)			{ self.__option_array_selected = _option_array; return self; }
				
				/// @method				getRawOptionArrayMouseover()
				/// @description		Gets the options text array of the group, for the mouseover state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the mouseover state, without Scribble formatting tags
				self.getRawOptionArrayMouseover = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_mouseover); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_mouseover[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArrayMouseover()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the mouseover state
				self.getOptionArrayMouseover = function()						{ return self.__option_array_mouseover; }
			
				/// @method				setOptionArrayMouseover(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArrayMouseover = function(_option_array)			{ self.__option_array_mouseover = _option_array; return self; }				
				
			
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the options group button when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getImageMouseover()
				/// @description		Gets the image index of the options group button when mouseovered.		
				/// @return				{Real}	The image index of the button when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the options group button when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getSpriteSelected()
				/// @description		Gets the sprite ID of the options group button used for the selected state.
				/// @return				{Asset.GMSprite}	The sprite ID of the options group button used for the selected state.
				self.getSpriteSelected = function()					{ return self.__sprite_selected; }
			
				/// @method				setSpriteSelected(_sprite)
				/// @description		Sets the sprite to be used for the selected state.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteSelected = function(_sprite)			{ self.__sprite_selected = _sprite; return self; }
			
				/// @method				getImageSelected()
				/// @description		Gets the image index of the options group button used for the selected state.
				/// @return				{Real}	The image index of the options group button used for the selected state.
				self.getImageSelected = function()					{ return self.__image_selected; }
			
				/// @method				setImageSelected(_image)
				/// @description		Sets the image index of the options group button used for the selected state.
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageSelected = function(_image)			{ self.__image_selected = _image; return self; }				
				
				/// @method				getSpriteUnselected()
				/// @description		Gets the sprite ID of the options group button used for the unselected state.	
				/// @return				{Asset.GMSprite}	The sprite ID of the options group button used for the unselected state.	
				self.getSpriteUnselected = function()				{ return self.__sprite_unselected; }
			
				/// @method				setSpriteUnselected(_sprite)
				/// @description		Sets the sprite to be used for the unselected state.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteUnselected = function(_sprite)			{ self.__sprite_unselected = _sprite; return self; }
			
				/// @method				getImageUnselected()
				/// @description		Gets the image index of the options group button used for the unselected state.		
				/// @return				{Real}	The image index of the options group button  used for the unselected state.	
				self.getImageUnselected = function()					{ return self.__image_unselected; }
			
				/// @method				setImageUnselected(_image)
				/// @description		Sets the image index of the options group button used for the unselected state.	
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageUnselected = function(_image)			{ self.__image_unselected = _image; return self; }
				
				/// @method				getIndex()
				/// @description		Gets the index of the selected option, or -1 if no option is currently selected.
				/// @return				{Real}	The selected option index
				self.getIndex = function()							{ return self.__index; }
				
				/// @method				setIndex(_index)
				/// @description		Sets the index of the selected option. If set to -1, it will select no options.<br>
				///						If the number provided exceeds the range of the options array, no change will be performed.
				/// @param				{Real}	_index	The index to set
				/// @return				{UIOptionGroup}	self
				self.setIndex = function(_index) {
					var _change = (_index != self.__index);
					self.__index = (_index == -1 ? -1 : clamp(_index, 0, array_length(self.__option_array_unselected)));
					if (_change)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					return self;
				}
				
				/// @method				getOptionRawText()
				/// @description		Gets the raw text of the selected option, or "" if no option is currently selected, without Scribble formatting tags
				/// @return				{String}	The selected option text
				self.getOptionRawText = function()					{ return self.__index == -1 ? "" : UI_TEXT_RENDERER(self.__option_array_selected[self.__index]).get_text(); }
				
				/// @method				getOptionText()
				/// @description		Gets the text of the selected option, or "" if no option is currently selected.
				/// @return				{String}	The selected option text
				self.getOptionText = function()						{ return self.__index == -1 ? "" : self.__option_array_selected[self.__index]; }
				
				/// @method				getVertical()
				/// @description		Gets whether the options group is rendered vertically (true) or horizontally (false)
				/// @return				{Bool}	Whether the group is rendered vertically
				self.getVertical = function()						{ return self.__vertical; }
				
				/// @method				setVertical(_is_vertical)
				/// @description		Sets whether the options group is rendered vertically (true) or horizontally (false)
				/// @param				{Bool}	_is_vertical	Whether to render the group vertically
				/// @return				{UIOptionGroup}	self
				self.setVertical = function(_is_vertical)			{ self.__vertical = _is_vertical; return self; }
				
				/// @method				getSpacing()
				/// @description		Gets the spacing between options when rendering
				/// @return				{Real}	The spacing in px
				self.getSpacing = function()						{ return self.__spacing; }
				
				/// @method				setSpacing(_spacing)
				/// @description		Sets the spacing between options when rendering
				/// @param				{Real}	_spacing	The spacing in px
				/// @return				{UIOptionGroup}	self
				self.setSpacing = function(_spacing)				{ self.__spacing = _spacing; return self; }
				
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _curr_x = _x;
					var _curr_y = _y;
					var _sum_width = 0;
					var _sum_height = 0;
					var _max_width = 0;
					var _max_height = 0;
					var _n=array_length(self.__option_array_unselected);
					
					self.__option_array_dimensions = array_create(_n);
					for (var _i=0; _i<_n; _i++)	self.__option_array_dimensions[_i] = {x:0, y:0, width:0, height:0};
					for (var _i=0; _i<_n; _i++) {
						var _sprite = self.__index == _i ? self.__sprite_selected : self.__sprite_unselected;
						var _image = self.__index == _i ? self.__image_selected : self.__image_unselected;
						var _text = self.__index == _i ? self.__option_array_selected[_i] : self.__option_array_unselected[_i];
						var _width = (self.__index == _i ? sprite_get_width(self.__sprite_selected) : sprite_get_width(self.__sprite_unselected)) * UI.getScale();
						var _height = (self.__index == _i ? sprite_get_height(self.__sprite_selected) : sprite_get_height(self.__sprite_unselected)) * UI.getScale();
						draw_sprite_stretched_ext(_sprite, _image, _curr_x, _curr_y, _width, _height, self.__image_blend, self.__image_alpha);
						var _scale = "[scale,"+string(UI.getScale())+"]";				
						var _s = UI_TEXT_RENDERER(_scale+_text);
						var _text_x = _curr_x + _width;
						var _text_y = _curr_y + _height/2;
						_s.draw(_text_x, _text_y);
						
						self.__option_array_dimensions[_i].x = _curr_x;
						self.__option_array_dimensions[_i].y = _curr_y;
						self.__option_array_dimensions[_i].width = _width + _s.get_width();
						self.__option_array_dimensions[_i].height = _height;
						
						if (self.__vertical) {
							_curr_y += _height + (_i<_n-1 ? self.__spacing : 0);
						}						
						else {
							_curr_x += _width + _s.get_width() + (_i<_n-1 ? self.__spacing : 0);
						}
						
						_sum_width += _width + _s.get_width() + (_i<_n-1 ? self.__spacing : 0);
						_sum_height += _height + (_i<_n-1 ? self.__spacing : 0);
						_max_width = max(_max_width, _width + _s.get_width());
						_max_height = max(_max_height, _height);
					}
					
					if (self.__vertical) {
						self.setDimensions(,, _max_width, _sum_height);
					}
					else {
						self.setDimensions(,, _sum_width, _max_height);
					}
					
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						var _clicked = -1;
						var _n=array_length(self.__option_array_unselected);
						var _i=0;
						while (_i<_n && _clicked == -1) {
							if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), self.__option_array_dimensions[_i].x, self.__option_array_dimensions[_i].y, self.__option_array_dimensions[_i].x + self.__option_array_dimensions[_i].width, self.__option_array_dimensions[_i].y + self.__option_array_dimensions[_i].height)) {
								_clicked = _i;
							}
							else {
								_i++;
							}
						}
						
						if (_clicked != -1 && _clicked != self.__index)	{
							self.setIndex(_clicked);
						}
					}
					
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UIDropDown
	
		/// @constructor	UIDropdown(_id, _x, _y, _option_array, _sprite, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIOptionGroup
		/// @description	A Dropdown widget, clickable UI widget that lets the user select from a list of values. Extends UIOptionGroup as it provides the same functionality with different interface.
		/// @param			{String}			_id					The Dropdown's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x					The x position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y					The y position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Array<String>}		_option_array		An array with at least one string that contains the text for each of the options
		/// @param			{Asset.GMSprite}	_sprite_background	The sprite ID to use for rendering the background of the list of values
		/// @param			{Asset.GMSprite}	_sprite				The sprite ID to use for rendering each value within the list of values
		/// @param			{Real}				[_initial_idx]		The initial selected index of the Dropdown list (default=0, the first option)
		/// @param			{Enum}				[_relative_to]		The position relative to which the Dropdown will be drawn. By default, the top left (TOP_LEFT) <br>
		///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIDropdown}							self
		//function UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, _initial_idx=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
		function UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, _initial_idx=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : UIOptionGroup(_id, _x, _y, _option_array, _sprite, _initial_idx, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.DROPDOWN;
				self.__sprite_arrow = grey_arrowDownWhite;
				self.__image_arrow = 0;
				self.__sprite_dropdown = _sprite_dropdown;
				self.__image_dropdown = 0;
				self.__dropdown_active = false;
			#endregion
			#region Setters/Getters			
				/// @method				getSpriteDropdown()
				/// @description		Gets the sprite ID of the dropdown background
				/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
				self.getSpriteDropdown = function()				{ return self.__sprite_dropdown; }
			
				/// @method				setSpriteDropdown(_sprite)
				/// @description		Sets the sprite ID of the dropdown background
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIDropdown}	self
				self.setSpriteDropdown = function(_sprite)			{ self.__sprite_dropdown = _sprite; return self; }
			
				/// @method				getImageDropdown()
				/// @description		Gets the image index of the dropdown background
				/// @return				{Real}	The image index of the dropdown background
				self.getImageDropdown = function()					{ return self.__image_dropdown; }
			
				/// @method				setImageDropdown(_image)
				/// @description		Sets the image index of the dropdown background
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageDropdown = function(_image)			{ self.__image_dropdown = _image; return self; }
				
				/// @method				getSpriteArrow()
				/// @description		Gets the sprite ID of the arrow icon for the dropdown
				/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
				self.getSpriteArrow = function()				{ return self.__sprite_arrow; }
			
				/// @method				setSpriteArrow(_sprite)
				/// @description		Sets the sprite ID of the arrow icon for the dropdown
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIArrow}	self
				self.setSpriteArrow = function(_sprite)			{ self.__sprite_arrow = _sprite; return self; }
			
				/// @method				getImageArrow()
				/// @description		Gets the image index of the arrow icon for the dropdown
				/// @return				{Real}	The image index of the arrow icon for the dropdown
				self.getImageArrow = function()					{ return self.__image_arrow; }
			
				/// @method				setImageArrow(_image)
				/// @description		Sets the image index of the arrow icon for the dropdown
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageArrow = function(_image)			{ self.__image_arrow = _image; return self; }
			
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _pad_left = 10;
					var _pad_right = 10 + sprite_get_width(self.__sprite_arrow);
					var _pad_top = 5 + sprite_get_height(self.__sprite_arrow)/2;
					var _pad_bottom = 5 + sprite_get_height(self.__sprite_arrow)/2;
					
					var _sprite = self.__sprite_selected;
					var _image = self.__image_selected;
					var _text = self.__option_array_selected[self.__index];
					var _scale = "[scale,"+string(UI.getScale())+"]";
					var _t = UI_TEXT_RENDERER(_scale+_text);						
					var _width = self.__dimensions.width == 0 ? _t.get_width() + _pad_left+_pad_right : self.__dimensions.width;
					var _height = _t.get_height() + _pad_top+_pad_bottom;
					
					if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y, _x + _width, _y + _height)) {
						_sprite =	self.__sprite_mouseover;
						_image =	self.__image_mouseover;
						_text =		self.__option_array_mouseover[self.__index];
						_t = UI_TEXT_RENDERER(_scale+_text);
					}
					
					draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
						
					var _x = _x + _pad_left;
					var _y = _y + _height * UI.getScale()/2;
					_t.draw(_x, _y);
						
					// Arrow
					var _x = self.__dimensions.x + _width - _pad_right;
					draw_sprite_ext(self.__sprite_arrow, self.__image_arrow, _x, _y - sprite_get_height(self.__sprite_arrow)/2, 1, 1, 0, self.__image_blend, self.__image_alpha);
					
					if (self.__dropdown_active) {  // Draw actual dropdown list
						var _x = self.__dimensions.x;
						var _y = self.__dimensions.y + _height;
						var _n = array_length(self.__option_array_unselected);
						draw_sprite_stretched_ext(self.__sprite_dropdown, self.__image_dropdown, _x, _y, _width, _height * _n + _pad_bottom, self.__image_blend, self.__image_alpha);
						
						var _cum_h = 0;
						_x += _pad_left;
						for (var _i=0; _i<_n; _i++) {
							_t = UI_TEXT_RENDERER(_scale+self.__option_array_unselected[_i]);
							if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
								_t = UI_TEXT_RENDERER(_scale+self.__option_array_mouseover[_i]);
							}
							_t.draw(_x, _y + _t.get_height() + _cum_h);
							_cum_h += _t.get_height();
							if (_i<_n-1)  _cum_h += self.__spacing;
						}
					}
					
					self.setDimensions(,,_width, self.__dropdown_active ? _height * (_n+1) + _pad_bottom : _height);
					
				}
				//self.__generalBuiltInBehaviors = method(self, __UIWidget.__builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						if (self.__dropdown_active) {
							
							
							var _pad_left = 10;
							var _pad_right = 10 + sprite_get_width(self.__sprite_arrow);
							var _pad_top = 5 + sprite_get_height(self.__sprite_arrow)/2;
							var _pad_bottom = 5 + sprite_get_height(self.__sprite_arrow)/2;
							var _scale = "[scale,"+string(UI.getScale())+"]";
							var _x = self.__dimensions.x;
							var _y = self.__dimensions.y + UI_TEXT_RENDERER(self.__option_array_selected[self.__index]).get_height() + _pad_top+_pad_bottom;
							
							var _width = self.__dimensions.width;							
							
							var _clicked = -1;
							var _n=array_length(self.__option_array_unselected);
							var _i=0;
							var _cum_h = 0;
							while (_i<_n && _clicked == -1) {
								_t = UI_TEXT_RENDERER(_scale+self.__option_array_mouseover[_i]);
								if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
									_clicked = _i;
								}
								else {
									_cum_h += _t.get_height();
									if (_i<_n-1)  _cum_h += self.__spacing;
									_i++;
								}
							}
						
							if (_clicked != -1 && _clicked != self.__index)	{
								self.setIndex(_clicked);
							}
							
							self.__dropdown_active = false;
						}
						else {
							self.__dropdown_active = true;
						}						
					}
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			// Do not register since it extends UIOptionGroup and that one already registers
			//self.__register();
			return self;
		}
	
	#endregion

	#region UIProgressBar
		
		/// @constructor	UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, [_orientation=UI_ORIENTATION.HORIZONTAL], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A UIProgressBar widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id					The UIProgressBar's name, a unique string ID. If the specified name is taken, the UIProgressBar will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x					The x position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y					The y position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Asset.GMSprite}	_sprite_base		The sprite ID to use for rendering the UIProgressBar base
		/// @param			{Asset.GMSprite}	_sprite_progress	The sprite ID to use for rendering the UIProgressBar handle
		/// @param			{Real}				_value				The initial value of the UIProgressBar
		/// @param			{Real}				_min_value			The minimum value of the UIProgressBar
		/// @param			{Real}				_max_value			The maximum value of the UIProgressBar
		/// @param			{Enum}				[_orientation]		The orientation of the UIProgressBar, according to UI_ORIENTATION. By default: HORIZONTAL
		/// @param			{Enum}				[_relative_to]		The position relative to which the UIProgressBar will be drawn. By default, the top left (TOP_LEFT) <br>
		///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIProgressBar}							self
		function UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, _orientation=UI_ORIENTATION.HORIZONTAL, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite_base, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.PROGRESSBAR;
				self.__sprite_base = _sprite_base;
				self.__sprite_progress = _sprite_progress;
				self.__image_base = 0;
				self.__image_progress = 0;
				self.__sprite_progress_anchor = {x: 0, y: 0};
				self.__text_value_anchor = {x: 0, y: 0};
				self.__value = _value;
				self.__min_value = _min_value;
				self.__max_value = _max_value;
				self.__show_value = false;
				self.__prefix = "";
				self.__suffix = "";
				self.__text_format = "";
				self.__render_progress_behavior = UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL;
				self.__progress_repeat_unit = 1;
				self.__orientation = _orientation;
			#endregion
			#region Setters/Getters				
				/// @method				getSpriteBase()
				/// @description		Gets the sprite ID used for the base of the progressbar, that will be drawn behind
				/// @return				{Asset.GMSprite}	The sprite ID used for the base of the progressbar.
				self.getSpriteBase = function()							{ return self.__sprite_base; }
			
				/// @method				setSpriteBase(_sprite)
				/// @description		Sets the sprite to be used for the base of the progessbar, that will be drawn behind 
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIProgressBar}	self
				self.setSpriteBase = function(_sprite)					{ self.__sprite_base = _sprite; return self; }
			
				/// @method				getImageBase()
				/// @description		Gets the image index of the sprite used for the base of the progressbar, that will be drawn behind
				/// @return				{Real}	The image index of the sprite used for the base of the progressbar
				self.getImageBase = function()							{ return self.__image_base; }
			
				/// @method				setImageBase(_image)
				/// @description		Sets the image index of the sprite used for the base of the progressbar, that will be drawn behind
				/// @param				{Real}	_image	The image index
				/// @return				{UIProgressbar}	self
				self.setImageBase = function(_image)					{ self.__image_base = _image; return self; }				
				
				/// @method				getSpriteProgress()
				/// @description		Gets the sprite ID used for rendering progress.
				/// @return				{Asset.GMSprite}	The sprite ID used for rendering progress.
				self.getSpriteProgress = function()						{ return self.__sprite_handle; }
			
				/// @method				setSpriteProgress(_sprite)
				/// @description		Sets the sprite to be used for rendering progress.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIProgressbar}	self
				self.setSpriteProgress = function(_sprite)				{ self.__sprite_handle = _sprite; return self; }
			
				/// @method				getImageProgress()
				/// @description		Gets the image index of the sprite used for rendering progress.
				/// @return				{Real}	The image index of the sprite used for rendering progress
				self.getImageProgress = function()						{ return self.__image_handle; }
			
				/// @method				setImageProgress(_image)
				/// @description		Sets the image index of the sprite used for rendering progress.
				/// @param				{Real}	_image	The image index
				/// @return				{UIProgressbar}	self
				self.setImageProgress = function(_image)					{ self.__image_handle = _image; return self; }		
												
				/// @method				getValue()
				/// @description		Gets the value of the progressbar
				/// @return				{Real}	the value of the progressbar
				self.getValue = function()								{ return self.__value; }
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the progressbar
				/// @param				{Real}	_value	the value to set for the progressbar
				/// @return				{UIProgressbar}	self
				self.setValue = function(_value) { 
					if (clamp(_value, self.__min_value, self.__max_value) != self.__value)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__value = clamp(_value, self.__min_value, self.__max_value);
					return self;
				}
				
				/// @method				getMinValue()
				/// @description		Gets the minimum value of the progressbar
				/// @return				{Real}	the minimum value of the progressbar
				self.getMinValue = function()							{ return self.__min_value; }
				
				/// @method				setMinValue(_min_value)
				/// @description		Sets the minimum value of the progressbar
				/// @param				{Real}	_min_value	the value to set
				/// @return				{UIProgressbar}	self
				self.setMinValue = function(_min_value)					{ self.__min_value = _min_value; return self; }
				
				/// @method				getMaxValue()
				/// @description		Gets the maximum value of the progressbar
				/// @return				{Real}	the maximum value of the progressbar
				self.getMaxValue = function()							{ return self.__max_value; }
				
				/// @method				setMaxValue(_max_value)
				/// @description		Sets the maximum value of the progressbar
				/// @param				{Real}	_max_value	the value to set
				/// @return				{UIProgressbar}	self
				self.setMaxValue = function(_max_value)					{ self.__max_value = _max_value; return self; }
				
				/// @method				getOrientation()
				/// @description		Gets the orientation of the progressbar according to UI_ORIENTATION. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
				/// @return				{Enum}	the orientation of the progressbar
				self.getOrientation = function()						{ return self.__orientation; }
				
				/// @method				setOrientation(_orientation)
				/// @description		Sets the orientation of the progressbar. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
				/// @param				{Enum}	_orientation	the orientation according to UI_ORIENTATION
				/// @return				{UIProgressbar}	self
				self.setOrientation = function(_orientation)			{ self.__orientation = _orientation; return self; }
				
				/// @method				getShowValue()
				/// @description		Gets whether the progressbar renders text for the value
				/// @return				{Bool}	whether the progressbar renders renders text for the value
				self.getShowValue = function()						{ return self.__show_value; }
				
				/// @method				setShowValue(_show_value)
				/// @description		Sets whether the progressbar renders text for the value
				/// @param				{Bool}	_value	whether the progressbar renders text for the value
				/// @return				{UIProgressbar}	self
				self.setShowValue = function(_show_value)				{ self.__show_value = _show_value; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the progressbar text
				/// @return				{String}	the Scribble text format used for the progressbar text
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the progressbar text
				/// @param				{Stirng}	_format	the Scribble text format used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
				/// @method				getPrefix()
				/// @description		Gets the prefix for the progressbar text
				/// @return				{String}	the Scribble prefix used for the progressbar text
				self.getPrefix = function()							{ return self.__prefix; }
				
				/// @method				setPrefix(_prefix)
				/// @description		Sets the prefix for the progressbar text
				/// @param				{Stirng}	_prefix	the Scribble prefix used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setPrefix = function(_prefix)					{ self.__prefix = _prefix; return self; }
				
				/// @method				getSuffix()
				/// @description		Gets the suffix for the progressbar text
				/// @return				{String}	the Scribble suffix used for the progressbar text
				self.getSuffix = function()							{ return self.__suffix; }
				
				/// @method				setSuffix(_suffix)
				/// @description		Sets the suffix for the progressbar text
				/// @param				{Stirng}	_suffix	the Scribble suffix used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setSuffix = function(_suffix)					{ self.__suffix = _suffix; return self; }
				
				/// @method				getRenderProgressBehavior()
				/// @description		Gets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
				///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
				///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
				///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
				///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
				///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
				/// @return				{Bool}	The image index of the sprite used for the base of the progressbar
				self.getRenderProgressBehavior = function()							{ return self.__render_progress_behavior; }
			
				/// @method				setRenderProgressBehavior(_progress_behavior)
				/// @description		Sets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
				///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
				///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
				///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
				///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
				///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
				/// @param				{Enum}	_progress_behavior	The desired rendering behavior of the progressbar
				/// @return				{UIProgressbar}	self
				self.setRenderProgressBehavior = function(_progress_behavior)					{ self.__render_progress_behavior = _progress_behavior; return self; }
				
				/// @method				getProgressRepeatUnit()
				/// @description		Gets the value that each repeated progress sprite occurrence represents.<br>
				///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three `(= floor(17/5))` times
				///						(provided the render mode is set to REPEAT using `setRenderProgressBehavior`).
				/// @return				{Real}	The value that each marking represents within the progress bar
				self.getProgressRepeatUnit = function()							{ return self.__progress_repeat_unit; }
			
				/// @method				setProgressRepeatUnit(_progress_repeat_unit)
				/// @description		Sets the value that each repeated progress sprite occurrence represents.<br>
				///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three (floor(17/5)) times
				///						(provided the render mode is set to progress repeat using `setRenderProgressRepeat`).				
				/// @param				{Real}	_progress_repeat_unit	The value that each marking represents within the progress bar
				/// @return				{UIProgressbar}	self
				self.setProgressRepeatUnit = function(_progress_repeat_unit)					{ self.__progress_repeat_unit = _progress_repeat_unit; return self; }
				
				/// @method				getSpriteProgressAnchor()
				/// @description		Gets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
				///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel)
				///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
				/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
				self.getSpriteProgressAnchor = function()						{ return self.__sprite_progress_anchor; }
				
				/// @method				setSpriteProgressAnchor(_anchor_struct)
				/// @description		Sets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
				///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel).
				///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
				/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
				/// @return				{UIProgressbar}	self
				self.setSpriteProgressAnchor = function(_anchor_struct)			{ self.__sprite_progress_anchor = _anchor_struct; return self; }
				
				/// @method				getTextValueAnchor()
				/// @description		Gets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
				/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
				self.getTextValueAnchor = function()						{ return self.__text_value_anchor; }
				
				/// @method				setTextValueAnchor(_anchor_struct)
				/// @description		Sets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
				/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
				/// @return				{UIProgressbar}	self
				self.setTextValueAnchor = function(_anchor_struct)			{ self.__text_value_anchor = _anchor_struct; return self; }
			#endregion
			#region Methods
				
				self.__draw = function() {
										
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _proportion = clamp((self.__value - self.__min_value)/(self.__max_value - self.__min_value), 0, 1);
					
					var _width_base = sprite_get_width(self.__sprite_base);
					var _height_base = sprite_get_height(self.__sprite_base);
					draw_sprite_ext(self.__sprite_base, self.__image_base, _x, _y, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
					
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						switch (self.__render_progress_behavior) {
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL:
								var _width_progress = sprite_get_width(self.__sprite_progress);
								var _height_progress = sprite_get_height(self.__sprite_progress);
								draw_sprite_part_ext(self.__sprite_progress, self.__sprite_progress, 0, 0, _width_progress * _proportion, _height_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y, UI.getScale(), UI.getScale(), self.__image_blend, self.__image_alpha);
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT:
								var _times = floor(self.__value / self.__progress_repeat_unit);
								var _w = sprite_get_width(self.__sprite_progress);
								for (var _i=0; _i<_times; _i++) {
									draw_sprite_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x + _i*_w, self.__dimensions.y + self.__sprite_progress_anchor.y, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
								}
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH:
								var _width_progress = sprite_get_width(self.__sprite_progress);
								var _height_progress = sprite_get_height(self.__sprite_progress);
								draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y, _proportion * _width_progress, _height_progress, self.__image_blend, self.__image_alpha);
								break;
						}
					}
					else {
						switch (self.__render_progress_behavior) {
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL:
								var _width_progress = sprite_get_width(self.__sprite_progress);
								var _height_progress = sprite_get_height(self.__sprite_progress);
								_y = self.__dimensions.y + self.__sprite_progress_anchor.y - _height_progress * _proportion;
								draw_sprite_part_ext(self.__sprite_progress, self.__image_progress, 0, _height_progress * (1-_proportion), _width_progress, _height_progress * _proportion, self.__dimensions.x + self.__sprite_progress_anchor.x, _y, UI.getScale(), UI.getScale(), self.__image_blend, self.__image_alpha);
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT:
								var _times = floor(self.__value / self.__progress_repeat_unit);
								var _h = sprite_get_height(self.__sprite_progress);
								for (var _i=0; _i<_times; _i++) {
									draw_sprite_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y - _i * _h, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
								}
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH:
								var _width_progress = sprite_get_width(self.__sprite_progress);
								var _height_progress = sprite_get_height(self.__sprite_progress);
								_y = self.__dimensions.y + self.__sprite_progress_anchor.y - _height_progress * _proportion;
								draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, _y, _width_progress, _height_progress * _proportion, self.__image_blend, self.__image_alpha);
								break;
						}
					}
					
					self.setDimensions(,, _width_base, _height_base);
					
					if (self.__show_value) {
						UI_TEXT_RENDERER(self.__text_format+self.__prefix+string(self.__value)+self.__suffix).draw(self.__dimensions.x + self.__text_value_anchor.x, self.__dimensions.y + self.__text_value_anchor.y);
					}
										
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					var _arr = array_create(UI_NUM_CALLBACKS, true);					
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UICanvas
	
		/// @constructor	UICanvas(_id, _x, _y, _width, _height, _surface, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Canvas widget, which lets you draw a custom drawn surface on a Panel. The surface will be streched to the values of `width` and `height`.<br>
		///					*WARNING: destroying the Canvas widget will NOT free the surface, you need to do that yourself to avoid a memory leak*<br>
		///					*WARNING: the widget itself does not handle recreating the surface if it's automatically destroyed by the target platform. You need to do that yourself.
		/// @param			{String}			_id				The Canvas's name, a unique string ID. If the specified name is taken, the Canvas will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Canvas, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{Real}				_width			The width of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{Real}				_height			The height of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{String}			_surface		The surface ID to draw
		/// @param			{Enum}				[_relative_to]	The position relative to which the Canvas will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UICanvas}							self
		function UICanvas(_id, _x, _y, _width, _height, _surface, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, -1, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.CANVAS;
				self.__surface_id = _surface;				
			#endregion
			#region Setters/Getters
				
				/// @method				getSurface()
				/// @description		Gets the id of the surface bound to the Canvas
				///	@return				{Asset.GMSurface}	the surface id
				self.getSurface = function()				{ return self.__surface_id; }
			
				/// @method				setSurface(_surface)
				/// @description		Sets the surface bound to the Canvas
				/// @param				{Asset.GMSurface}	_surface	The surface id
				/// @return				{UICanvas}	self
				self.setSurface = function(_color)			{ self.__background_color = _color; return self; }
			
			#endregion
			#region Methods
				self.__draw = function() {
					if (surface_exists(self.__surface_id)) {						
						draw_surface_stretched_ext(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * UI.getScale(), self.__dimensions.height * UI.getScale(), self.__image_blend, self.__image_alpha);
					}
					else {
						UI.__logMessage("Surface bound to Canvas widget '"+self.__ID+"' does not exist.", UI_MESSAGE_LEVEL.WARNING);
					}
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					var _arr = array_create(UI_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

#endregion

#region Helper Structs
	function None() {}
	
	#region	__UIDimensions
		/// @struct					__UIDimensions(_offset_x, _offset_y, _width, _height,  _id, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _inherit_width=false, _inherit_height=false)
		/// @description			Private struct that represents the position and size of a particular Widget<br>
		///							Apart from the specified offset_x and offset_y, the resulting struct will also have:<br>
		///							`x`			x coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
		///							`y`			y coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
		///							`x_parent`	x coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).<br>
		///							`y_parent`	y coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).
		///	@param					{Real}		_offset_x			Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
		///															This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
		///	@param					{Real}		_offset_y			Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
		///															This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
		///	@param					{Real}		_width				Width of widget
		///	@param					{Real}		_height				Height of widget
		///	@param					{UIWidget}	_id					ID of the corresponing widget
		///	@param					{Enum}		[_relative_to]		Relative to, according to `UI_RELATIVE_TO` enum
		///	@param					{UIWidget}	[_parent]			Reference to the parent, or noone		
		///	@param					{UIWidget}	[_inherit_width]	Whether the widget inherits its width from its parent
		///	@param					{UIWidget}	[_inherit_height]	Whether the widget inherits its height from its parent
		function __UIDimensions(_offset_x, _offset_y, _width, _height, _id, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _inherit_width=false, _inherit_height=false) constructor {
			self.widget_id = _id;
			self.relative_to = _relative_to;
			self.offset_x = _offset_x;
			self.offset_y = _offset_y;
			self.width = _width;
			self.height = _height;
			self.inherit_width = _inherit_width;
			self.inherit_height = _inherit_height;
			self.parent = noone;
		
			// These values are ALWAYS the coordinates of the top-left corner, irrespective of the relative_to value
			self.x = 0;
			self.y = 0;
			self.relative_x = 0;
			self.relative_y = 0;
		
			/// @method			calculateCoordinates()
			/// @description	computes the relative and absolute coordinates, according to the set parent		
			self.calculateCoordinates = function() {
				// Get parent x,y SCREEN TOP-LEFT coordinates and width,height (if no parent, use GUI size)
				var _parent_x = 0;
				var _parent_y = 0;
				var _parent_w = display_get_gui_width();
				var _parent_h = display_get_gui_height();
				if (self.parent != noone) {
					_parent_x = self.parent.__dimensions.x;
					_parent_y = self.parent.__dimensions.y;
					_parent_w = self.parent.__dimensions.width;
					_parent_h = self.parent.__dimensions.height;
				}
				// Inherit width/height
				if (self.inherit_width)		self.width = self.parent.__dimensions.width;
				if (self.inherit_height)	self.height = self.parent.__dimensions.height;
				// Calculate the starting point
				var _starting_point_x = _parent_x;
				var _starting_point_y = _parent_y;
				if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
					_starting_point_x += _parent_w/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					_starting_point_x += _parent_w;
				}
				if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
					_starting_point_y += _parent_h/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					_starting_point_y += _parent_h;
				}
				// Calculate anchor point
				var _anchor_point_x = _starting_point_x + self.offset_x;
				var _anchor_point_y = _starting_point_y + self.offset_y;
				// Calculate widget TOP_LEFT SCREEN x,y coordinates (absolute)
				self.x = _anchor_point_x;
				self.y = _anchor_point_y;
				if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
					self.x -= self.width/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					self.x -= self.width;
				}
				if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
					self.y -= self.height/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					self.y -= self.height;
				}
				// Calculate widget RELATIVE x,y coordinates (relative to parent)
				self.relative_x = self.x - _parent_x;
				self.relative_y = self.y - _parent_y;			
			}
		
		
			/// @method					setParent(_parent)
			/// @description			sets the parent of the UIDimensions struct, so coordinates can be calculated taking that parent into account.<br>
			///							Coordinates are automatically updated when set - i.e. [`calculateCoordinates()`](#__UIDimensions.calculateCoordinates) is automatically called.
			/// @param					{UIWidget}	_parent		the reference to the UIWidget		
			self.setParent = function(_parent) {
				self.parent = _parent;
				// Update screen and relative coordinates with new parent
				self.calculateCoordinates();
			}
		
			/// @method					set(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to=undefined)
			/// @description			sets the values for the struct, with optional parameters
			///	@param					{Real}		[_offset_x]		Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
			///														This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
			///	@param					{Real}		[_offset_y]		Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
			///														This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
			///	@param					{Real}		[_width]		Width of widget
			///	@param					{Real}		[_height]		Height of widget				
			///	@param					{Enum}		[_parent]		Sets the anchor relative to which coordinates are calculated.
			self.set = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to = undefined) {
				self.offset_x = _offset_x ?? self.offset_x;
				self.offset_y = _offset_y ?? self.offset_y;
				self.relative_to = _relative_to ?? self.relative_to;
				self.width = _width ?? self.width;
				self.height = _height ?? self.height;
				// Update screen and relative coordinates with new parent
				self.calculateCoordinates();
			}
			
			self.setScrollOffsetH = function(_signed_amount) {
				self.offset_x = self.offset_x + _signed_amount;
				// Update screen and relative coordinates with scroll
				self.calculateCoordinates();
			}
			self.setScrollOffsetV = function(_signed_amount) {
				self.offset_y = self.offset_y + _signed_amount;
				// Update screen and relative coordinates with scroll
				self.calculateCoordinates();
			}
			
			self.toString = function() {
				var _rel;
				switch (self.relative_to) {
					case UI_RELATIVE_TO.TOP_LEFT:		_rel = "top left";			break;
					case UI_RELATIVE_TO.TOP_CENTER:		_rel = "top center";		break;
					case UI_RELATIVE_TO.TOP_RIGHT:		_rel = "top right";			break;
					case UI_RELATIVE_TO.MIDDLE_LEFT:	_rel = "middle left";		break;
					case UI_RELATIVE_TO.MIDDLE_CENTER:	_rel = "middle center";		break;
					case UI_RELATIVE_TO.MIDDLE_RIGHT:	_rel = "middle right";		break;
					case UI_RELATIVE_TO.BOTTOM_LEFT:	_rel = "bottom left";		break;
					case UI_RELATIVE_TO.BOTTOM_CENTER:	_rel = "bottom center";		break;
					case UI_RELATIVE_TO.BOTTOM_RIGHT:	_rel = "bottom right";		break;
					default:							_rel = "UNKNOWN";			break;
				}
				return self.widget_id.__ID + ": ("+string(self.x)+", "+string(self.y)+") relative to "+_rel+"  width="+string(self.width)+" height="+string(self.height)+
				" offset provided: "+string(self.offset_x)+","+string(self.offset_y)+
				"\n	parent: "+(self.parent != noone ? self.parent.__ID + " ("+(string(self.parent.__dimensions.x)+", "+string(self.parent.__dimensions.y)+")   width="+string(self.parent.__dimensions.width)+" height="+string(self.parent.__dimensions.height)) : "no parent");
			}
			
			// Set parent (and calculate screen/relative coordinates) on creation
			self.setParent(_parent);
		}	
	
	#endregion
	
	#region __UIWidget
	
		/// @constructor	UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT)
		/// @description	The base class for all ofhter widgets. Should be treated as an
		///					uninstantiable class / template.
		/// @param	{String}				_id					The widget's string ID by which it will be referred as.
		/// @param	{Real}					_offset_x			The x offset position relative to its parent, according to the _relative_to parameter
		/// @param	{Real}					_offset_y			The y offset position relative to its parent, according to the _relative_to parameter
		/// @param	{Real}					_width				The width of the widget
		/// @param	{Real}					_height				The height of the widget
		/// @param	{Asset.GMSprite}		_sprite				The sprite asset to use for rendering
		/// @param	{Enum}					[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
		/// @return	{UIWidget}				self
		function __UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) constructor {
			#region Private variables
				self.__ID = _id;
				self.__type = -1;
				self.__dimensions = new __UIDimensions(_offset_x, _offset_y, _width, _height, self, _relative_to, noone, false, false);
				self.__sprite = _sprite;
				self.__image = 0;
				self.__image_alpha = 1;
				self.__image_blend = c_white;				
				self.__events_fired_last = array_create(UI_NUM_CALLBACKS, false);
				self.__events_fired = array_create(UI_NUM_CALLBACKS, false);
				self.__callbacks = array_create(UI_NUM_CALLBACKS, None);
				self.__parent = noone;
				self.__children = [];
				//self.__builtInBehavior = None;			
				self.__visible = true;
				self.__enabled = true;
				self.__draggable = false;			
				self.__resizable = false;
				self.__resize_border_width = 0;
				self.__drag_bar_height = self.__dimensions.height;
				self.__clips_content = false;
				self.__surface_id = noone;
				self.__min_width = 1;
				self.__min_height = 1;
				self.__user_data = {};
				self.__cumulative_horizontal_scroll_offset = [0];
				self.__cumulative_vertical_scroll_offset = [0];
			#endregion
			#region Setters/Getters
				/// @method				getID()
				/// @description		Getter for the widget's string ID
				/// @returns			{string} The widget's string ID
				self.getID = function()					{ return self.__ID; }
			
				/// @method				getType()
				/// @description		Getter for the widget's type
				/// @returns			{Enum}	The widget's type, according to the UI_TYPE enum			
				self.getType = function()					{ return self.__type; }
			
				/// @method				getDimensions()
				/// @description		Gets the UIDimensions object for this widget
				/// @returns			{UIDimensions}	The dimensions object. See [`UIDimensions`](#__UIDimensions).
				self.getDimensions = function()			{ return self.__dimensions; }
			
				/// @method						setDimensions()
				/// @description				Sets the UIDimensions object for this widget, with optional parameters.
				/// @param	{Real}				[_offset_x]			The x offset position relative to its parent, according to the _relative_to parameter
				/// @param	{Real}				[_offset_y]			The y offset position relative to its parent, according to the _relative_to parameter
				/// @param	{Real}				[_width]			The width of the widget
				/// @param	{Real}				[_height]			The height of the widget			
				/// @param	{Enum}				[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
				/// @param	{UIWidget}			[_parent]			Parent Widget reference
				/// @return						{UIWidget}	self
				self.setDimensions = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to = undefined, _parent = undefined)	{
					self.__dimensions.set(_offset_x, _offset_y, _width, _height, _relative_to, _parent);					
					return self;
				}
				
				/// @method				getInheritWidth()
				/// @description		Gets whether the widget inherits its width from its parent.
				/// @returns			{Bool}	Whether the widget inherits its width from its parent
				self.getInheritWidth = function()						{ return self.__dimensions.inherit_width; }
				
				/// @method				setInheritWidth(_inherit_width)
				/// @description		Sets whether the widget inherits its width from its parent.
				/// @param				{Bool}	_inherit_width	Whether the widget inherits its width from its parent
				/// @return				{UIWidget}	self
				self.setInheritWidth = function(_inherit_width) { 
					self.__dimensions.inherit_width = _inherit_width; 
					self.__dimensions.calculateCoordinates();
					self.__updateChildrenPositions();
					return self;
				}
				
				/// @method				getInheritHeight()
				/// @description		Gets whether the widget inherits its height from its parent.
				/// @returns			{Bool}	Whether the widget inherits its height from its parent
				self.getInheritHeight = function()					{ return self.__dimensions.inherit_height; }
				
				/// @method				setInheritHeight(_inherit_height)
				/// @description		Sets whether the widget inherits its height from its parent.
				/// @param				{Bool}	_inherit_height Whether the widget inherits its height from its parent
				/// @return				{UIWidget}	self
				self.setInheritHeight = function(_inherit_height)	{ 
					self.__dimensions.inherit_height = _inherit_height;
					self.__dimensions.calculateCoordinates();
					self.__updateChildrenPositions();
					return self;
				}
				
			
				/// @method				getSprite(_sprite)
				/// @description		Get the sprite ID to be rendered
				/// @return				{Asset.GMSprite}	The sprite ID
				self.getSprite = function()				{ return self.__sprite; }
			
				/// @method				setSprite(_sprite)
				/// @description		Sets the sprite to be rendered
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIWidget}	self
				self.setSprite = function(_sprite)		{ self.__sprite = _sprite; return self; }
			
				/// @method				getImage()
				/// @description		Gets the image index of the Widget
				/// @return				{Real}	The image index of the Widget
				self.getImage = function()				{ return self.__image_; }
			
				/// @method				setImage(_image)
				/// @description		Sets the image index of the Widget
				/// @param				{Real}	_image	The image index
				/// @return				{UIWidget}	self
				self.setImage = function(_image)			{ self.__image = _image; return self; }
				
				/// @method				getImageBlend()
				/// @description		Gets the image blend of the Widget's sprite
				/// @return				{Constant.Color}	The image blend
				self.getImageBlend = function()			{ return self.__image_blend; }
			
				/// @method				setImageBlend(_color)
				/// @description		Sets the image blend of the Widget
				/// @param				{Constant.Color}	_color	The image blend
				/// @return				{UIWidget}	self
				self.setImageBlend = function(_color)		{ self.__image_blend = _color; return self; }
				
				/// @method				getImageAlpha()
				/// @description		Gets the image alpha of the Widget's sprite
				/// @return				{Real}	The image alpha
				self.getImageAlpha = function()			{ return self.__image_alpha; }
			
				/// @method				setImageAlpha(_color)
				/// @description		Sets the image alpha of the Widget
				/// @param				{Real}	_alpha	The image alpha
				/// @return				{UIWidget}	self
				self.setImageAlpha = function(_alpha)		{ self.__image_alpha = _alpha; return self; }
				
				/// @method				getCallback(_callback_type)
				/// @description		Gets the callback function for a specific callback type, according to the `UI_EVENT` enum
				/// @param				{Enum}	_callback_type	The callback type
				/// @return				{Function}	the callback function
				self.getCallback = function(_callback_type)				{ return self.__callbacks[_callback_type]; }
			
				/// @method				setCallback(_callback_type, _function)
				/// @description		Sets a callback function for a specific event
				/// @param				{Enum}	_callback_type	The callback type, according to `UI_EVENT` enum
				/// @param				{Function}	_function	The callback function to assign
				/// @return				{UIWidget}	self
				self.setCallback = function(_callback_type, _function)	{ self.__callbacks[_callback_type] = _function; return self; }
			
				/// @method				getParent()
				/// @description		Gets the parent reference of the Widget (also a Widget)			
				/// @return				{UIWidget}	the parent reference
				self.getParent = function()				{ return self.__parent; }
			
				/// @method				getContainingPanel()
				/// @description		Gets the reference of the Panel containing this Widget. If this Widget is a Panel, it will return itself.
				/// @return				{UIPanel}	the parent reference
				self.getContainingPanel = function() {
					if (self.__type == UI_TYPE.PANEL)	return self;
					else if (self.__parent.__type == UI_TYPE.PANEL)	return self.__parent;
					else return self.__parent.getContainingPanel();
				}
				
				/// @method				getContainingTab()
				/// @description		Gets the index number of the tab of the Panel containing this Widget. <br>
				///						If this Widget is a common widget, it will return -1.<br>
				///						If this Widget is a Panel, it will return -4;
				/// @return				{Real}	the tab number
				self.getContainingTab = function() {					
					if (self.__type == UI_TYPE.PANEL)	return -4;
					else {
						var _parent_widget = self.__parent;
						var _target_widget = self;
						while (_parent_widget.__type != UI_TYPE.PANEL) {
							_parent_widget = _parent_widget.__parent;
							_target_widget = _target_widget.__parent;
						}
						var _i=0, _n=array_length(_parent_widget.__tabs); 
						var _found = false;
						while (_i<_n && !_found) {
							var _j=0, _m=array_length(_parent_widget.__tabs[_i]);
							while (_j<_m && !_found) {
								_found = (_parent_widget.__tabs[_i][_j] == _target_widget);
								if (!_found) _j++;
							}
							if (!_found) _i++; 
						}
						if (!_found) { // Must be common controls, return -1 - but calculate it anyway
							var _k=0; 
							var _o=array_length(_parent_widget.__common_widgets);
							var _found_common = false;
							while (_k<_o && !_found_common) {
								_found_common = (_parent_widget.__common_widgets[_k] == _target_widget);
								if (!_found_common) _k++;
							}
							if (_found_common)	return -1;
							else throw("Something REALLY weird happened, the specified control isn't anywhere. Run far, far away");
						}
						else {
							return _i;
						}
					}
				}
			
				/// @method				setParent(_parent_id)
				/// @description		Sets the parent of the Widget. Also calls the `setParent()` method of the corresponding `UIDimensions` struct to recalculate coordinates.
				/// @param				{UIWidget}	_parent_id	The reference to the parent Widget
				/// @return				{UIWidget}	self
				self.setParent = function(_parent_id)		{ 
					self.__parent = _parent_id;
					self.__dimensions.setParent(_parent_id);
					return self;
				}
			
				/// @method				getChildren([_tab=<current tab>])
				/// @description		Gets the array containing all children of this Widget
				/// @param				{Real}	[_tab]				Tab to get the controls from. <br>
				///													If _tab is a nonnegative number, it will get the children from the specified tab.<br>
				///													If _tab is -1, it will return the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).
				/// @return				{Array<UIWidget>}	the array of children Widget references
				self.getChildren = function(_tab=self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			return self.__tabs[_tab];
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	return self.__common_widgets;
					else													return self.__children;
				}
			
				/// @method				setChildren(_children, [_tab=<current tab>])
				/// @description		Sets the children Widgets to a new array of Widget references
				/// @param				{Array<UIWidget>}	_children	The array containing the references of the children Widgets
				/// @param				{Real}				[_tab]		Tab to set the controls for. <br>
				///														If _tab is a nonnegative number, it will set the children of the specified tab.<br>
				///														If _tab is -1, it will set the common widgets instead.<br>
				///														If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{UIWidget}	self
				self.setChildren = function(_children, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			self.__tabs[_tab] = _children;
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	self.__common_widgets = _children;
					else													self.__children = _children; 
					return self;
				}
			
				/// @method				getVisible()
				/// @description		Gets the visible state of a Widget
				/// @return				{Bool}	whether the Widget is visible or not
				self.getVisible = function()				{ return self.__visible; }
			
				/// @method				setVisible(_visible)
				/// @description		Sets the visible state of a Widget
				/// @param				{Bool}	_visible	Whether to set visibility to true or false			
				/// @return				{UIWidget}	self
				self.setVisible = function(_visible)		{
					self.__visible = _visible; 
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].setVisible(_visible);
					}
					return self;
				}
			
				/// @method				getEnabled()
				/// @description		Gets the enabled state of a Widget
				/// @return				{Bool}	whether the Widget is enabled or not
				self.getEnabled = function()				{ return self.__enabled; }
			
				/// @method				setEnabled(_enabled)
				/// @description		Sets the enabled state of a Widget
				/// @param				{Bool}	_enabled	Whether to set enabled to true or false			
				/// @return				{UIWidget}	self			
				self.setEnabled = function(_enabled)		{
					self.__enabled = _enabled;
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].setEnabled(_enabled);
					}
					return self;
				}
			
				/// @method				getDraggable()
				/// @description		Gets the draggable state of a Widget
				/// @return				{Bool}	whether the Widget is draggable or not
				self.getDraggable = function()			{ return self.__draggable; }
			
				/// @method				setDraggable(_draggable)
				/// @description		Sets the draggable state of a Widget
				/// @param				{Bool}	_draggable	Whether to set draggable to true or false			
				/// @return				{UIWidget}	self
				self.setDraggable = function(_draggable)	{ self.__draggable = _draggable; return self; }
			
				/// @method				getResizable()
				/// @description		Gets the resizable state of a Widget
				/// @return				{Bool}	whether the Widget is resizable or not
				self.getResizable = function()			{ return self.__resizable; }
			
				/// @method				setResizable(_resizable)
				/// @description		Sets the resizable state of a Widget
				/// @param				{Bool}	_resizable	Whether to set resizable to true or false			
				/// @return				{UIWidget}	self
				self.setResizable = function(_resizable)	{ self.__resizable = _resizable; return self; }
			
				/// @method				getResizeBorderWidth()
				/// @description		Gets the width of the border of a Widget that enables resizing
				/// @return				{Real}	the width of the border in px
				self.getResizeBorderWidth = function()		{ return self.__resize_border_width; }
			
				/// @method				setResizeBorderWidth(_resizable)
				/// @description		Sets the resizable state of a Widget
				/// @param				{Real}	_border_width	The width of the border in px
				/// @return				{UIWidget}	self
				self.setResizeBorderWidth = function(_border_width)		{ self.__resize_border_width = _border_width; return self; }
			
				/// @method				getClipsContent()
				/// @description		Gets the Widget's masking/clipping state
				/// @return				{Bool}	Whether the widget clips its content or not.
				self.getClipsContent = function()			{ return self.__clips_content; }
			
				/// @method				setClipsContent(_clips)
				/// @description		Sets the Widget's masking/clipping state.<br>
				///						Note this method automatically creates/frees the corresponding surfaces.
				/// @param				{Bool}	_clips	Whether the widget clips its content or not.
				/// @return				{UIWidget}	self
				self.setClipsContent = function(_clips) {
					self.__clips_content = _clips;
					if (_clips) {
						if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
					}
					else {
						if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
						self.__surface_id = noone;
					}
					return self;
				}	
				
				/// @method				getUserData(_name)
				/// @description		Gets the user data element named `_name`.
				/// @param				{String}	_name	the name of the data element
				/// @return				{String}	The user data value for the specified name, or an empty string if it doesn't exist
				self.getUserData = function(_name) {
					if (variable_struct_exists(self.__user_data, _name)) {
						return variable_struct_get(self.__user_data, _name);
					}
					else {
						UI.__logMessage("Cannot find data element with name '"+_name+"' in widget '"+self.__ID+"', returning blank string", UI_MESSAGE_LEVEL.WARNING);
						return "";
					}
				}
				
				/// @method				setUserData(_name, _value)
				/// @description		Sets the user data element named `_name`.
				/// @param				{String}	_name	the name of the data element
				/// @param				{Any}		_value	the value to set
				/// @return				{UIWidget}	self
				self.setUserData = function(_name, _value) {
					variable_struct_set(self.__user_data, _name, _value);
					return self;
				}
				
				
			#endregion
			#region Methods
			
				#region Private
					
					self.__register = function() {
						UI.__register(self);
					}
			
					self.__updateChildrenPositions = function() {
						
						if (self.__type == UI_TYPE.PANEL) {
							for (var _j=0, _m=array_length(self.__tabs); _j<_m; _j++) {
								for (var _i=0, _n=array_length(self.__tabs[_j]); _i<_n; _i++) {
									self.__tabs[_j][_i].__dimensions.calculateCoordinates();
									self.__tabs[_j][_i].__updateChildrenPositions();
								}
							}
							// Update common widgets as well
							for (var _i=0, _n=array_length(self.__common_widgets); _i<_n; _i++) {
								self.__common_widgets[_i].__dimensions.calculateCoordinates();
								self.__common_widgets[_i].__updateChildrenPositions();
							}	
						}
						else {
							for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
								self.__children[_i].__dimensions.calculateCoordinates();
								self.__children[_i].__updateChildrenPositions();							
							}
						}
					}
			
					self.__render = function() {
						if (self.__visible) {
							// Draw this widget
							self.__draw();
					
							if (self.__clips_content) {
								if (!surface_exists(self.__surface_id)) self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
								surface_set_target(self.__surface_id);
								draw_clear_alpha(c_black, 0);
							}
										
							// Render children
							for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].__render();
							// Render common items
							if (self.__type == UI_TYPE.PANEL) {
								for (var _i=0, _n=array_length(self.__common_widgets); _i<_n; _i++)	self.__common_widgets[_i].__render();
							}
					
							if (self.__clips_content) {						
								surface_reset_target();
								// The surface needs to be drawn with screen coords
								draw_surface_part(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * UI.getScale(), self.__dimensions.height * UI.getScale(), self.__dimensions.x, self.__dimensions.y);
							}
						}
					}
			
					self.__processMouseover = function() {
						if (self.__visible && self.__enabled)	self.__events_fired[UI_EVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), self.__dimensions.x, self.__dimensions.y, self.__dimensions.x + self.__dimensions.width * UI.getScale(), self.__dimensions.y + self.__dimensions.height * UI.getScale());
					}
					
					self.__clearEvents = function() {
						for (var _i=0; _i<UI_NUM_CALLBACKS; _i++)	self.__events_fired[_i] = false;
					}
				
					self.__processEvents = function() {
						array_copy(self.__events_fired_last, 0, self.__events_fired, 0, UI_NUM_CALLBACKS);
						
						self.__clearEvents();
						
						if (self.__visible && self.__enabled) {
							self.__processMouseover();
							self.__events_fired[UI_EVENT.LEFT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.LEFT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.LEFT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.MOUSE_ENTER] = !self.__events_fired_last[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER];
							self.__events_fired[UI_EVENT.MOUSE_EXIT] = self.__events_fired_last[UI_EVENT.MOUSE_OVER] && !self.__events_fired[UI_EVENT.MOUSE_OVER];
							self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_up();
							self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_down();
							
							// Calculate 3x3 "grid" on the panel, based off on screen coords, that will determine what drag action is fired (move or resize)
							var _w = self.__resize_border_width * UI.getScale();					
							var _x0 = self.__dimensions.x;
							var _x1 = _x0 + _w;
							var _x3 = self.__dimensions.x + self.__dimensions.width * UI.getScale();
							var _x2 = _x3 - _w;
							var _y0 = self.__dimensions.y;
							var _y1 = _y0 + _w;
							var _y3 = self.__dimensions.y + self.__dimensions.height * UI.getScale();
							var _y2 = _y3 - _w;
					
							// Determine mouse cursors for mouseover
							if (self.__events_fired[UI_EVENT.MOUSE_OVER]) {
								var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
								if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y1))				window_set_cursor(cr_size_nwse);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y1))		window_set_cursor(cr_size_nesw);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x1, _y3))		window_set_cursor(cr_size_nesw);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y2, _x3, _y3))		window_set_cursor(cr_size_nwse);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x3, _y1))		window_set_cursor(cr_size_ns);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y3))		window_set_cursor(cr_size_we);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x3, _y3))		window_set_cursor(cr_size_ns);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y3))		window_set_cursor(cr_size_we);
								else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))	window_set_cursor(cr_drag);
							}
					
							if (self.__isDragStart())	{
								// Determine drag actions for left hold
								var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
								if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))			UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_NW; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_NE; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_SW; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_SE; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_N;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_E;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_S;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_W;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	UI.__drag_data.__drag_action = UI_RESIZE_DRAG.DRAG;
								else 	UI.__drag_data.__drag_action = UI_RESIZE_DRAG.NONE;
								show_debug_message("Just assigned dragged widget to "+self.__ID+" with drag action "+string(UI.__drag_data.__drag_action));
							}
														
						}
					}
					
					self.__isDragStart = function() {
						if (UI.__currentlyDraggedWidget == noone && self.__events_fired[UI_EVENT.LEFT_HOLD])	{
							UI.setFocusedPanel(self.__ID);
							UI.__currentlyDraggedWidget = self;								
							UI.__drag_data.__drag_start_x = self.__dimensions.x;
							UI.__drag_data.__drag_start_y = self.__dimensions.y;
							UI.__drag_data.__drag_start_width = self.__dimensions.width;
							UI.__drag_data.__drag_start_height = self.__dimensions.height;
							UI.__drag_data.__drag_mouse_delta_x = device_mouse_x_to_gui(UI.getMouseDevice());
							UI.__drag_data.__drag_mouse_delta_y = device_mouse_y_to_gui(UI.getMouseDevice());
							return true;
						}
						else return false;
					}
					
					self.__isDragEnd = function() {
						if (UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(UI.getMouseDevice(), mb_left)) {								
							UI.__currentlyDraggedWidget = noone;
							UI.__drag_data.__drag_start_x = -1;
							UI.__drag_data.__drag_start_y = -1;
							UI.__drag_data.__drag_start_width = -1;
							UI.__drag_data.__drag_start_height = -1;
							UI.__drag_data.__drag_mouse_delta_x = -1;
							UI.__drag_data.__drag_mouse_delta_y = -1;
							UI.__drag_data.__drag_action = -1;
							window_set_cursor(cr_default);
							return true;
						}
						else return false;
					}
					
					self.__builtInBehavior = function(_process_array = array_create(UI_NUM_CALLBACKS, true)) {
						if (_process_array[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER]) 				self.__callbacks[UI_EVENT.MOUSE_OVER]();
						if (_process_array[UI_EVENT.LEFT_CLICK] && self.__events_fired[UI_EVENT.LEFT_CLICK]) 				self.__callbacks[UI_EVENT.LEFT_CLICK]();
						if (_process_array[UI_EVENT.MIDDLE_CLICK] && self.__events_fired[UI_EVENT.MIDDLE_CLICK]) 			self.__callbacks[UI_EVENT.MIDDLE_CLICK]();
						if (_process_array[UI_EVENT.RIGHT_CLICK] && self.__events_fired[UI_EVENT.RIGHT_CLICK]) 				self.__callbacks[UI_EVENT.RIGHT_CLICK]();
						if (_process_array[UI_EVENT.LEFT_HOLD] && self.__events_fired[UI_EVENT.LEFT_HOLD]) 					self.__callbacks[UI_EVENT.LEFT_HOLD]();
						if (_process_array[UI_EVENT.MIDDLE_HOLD] && self.__events_fired[UI_EVENT.MIDDLE_HOLD]) 				self.__callbacks[UI_EVENT.MIDDLE_HOLD]();
						if (_process_array[UI_EVENT.RIGHT_HOLD] && self.__events_fired[UI_EVENT.RIGHT_HOLD]) 				self.__callbacks[UI_EVENT.RIGHT_HOLD]();
						if (_process_array[UI_EVENT.LEFT_RELEASE] && self.__events_fired[UI_EVENT.LEFT_RELEASE]) 			self.__callbacks[UI_EVENT.LEFT_RELEASE]();
						if (_process_array[UI_EVENT.MIDDLE_RELEASE] && self.__events_fired[UI_EVENT.MIDDLE_RELEASE])		self.__callbacks[UI_EVENT.MIDDLE_RELEASE]();
						if (_process_array[UI_EVENT.RIGHT_RELEASE] && self.__events_fired[UI_EVENT.RIGHT_RELEASE]) 			self.__callbacks[UI_EVENT.RIGHT_RELEASE]();
						if (_process_array[UI_EVENT.MOUSE_ENTER] && self.__events_fired[UI_EVENT.MOUSE_ENTER]) 				self.__callbacks[UI_EVENT.MOUSE_ENTER]();
						if (_process_array[UI_EVENT.MOUSE_EXIT] && self.__events_fired[UI_EVENT.MOUSE_EXIT]) 				self.__callbacks[UI_EVENT.MOUSE_EXIT]();
						if (_process_array[UI_EVENT.MOUSE_WHEEL_UP] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP]) 		self.__callbacks[UI_EVENT.MOUSE_WHEEL_UP]();
						if (_process_array[UI_EVENT.MOUSE_WHEEL_DOWN] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN])	self.__callbacks[UI_EVENT.MOUSE_WHEEL_DOWN]();					
						// Handle Value Changed event on the UI object
					}	
			
				#endregion
			
				/// @method				scroll(_direction, _sign, [_amount = UI_SCROLL_SPEED])
				/// @description		Scrolls the content of this widget in a particular direction (horizontal/vertical) and sign (negative/positive)
				/// @param				{Enum}	_direction	the direction to scroll, as in `UI_ORIENTATION`.
				/// @param				{Real}	_sign		the sign (-1 or 1)
				/// @param				{Real}	_amount		the amount to scroll, by default `UI_SCROLL_SPEED`
				/// @return				{UIWidget}	self
				self.scroll = function(_direction, _sign, _amount = UI_SCROLL_SPEED) {
					var _s = _sign >= 0 ? 1 : -1;
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					if (_direction == UI_ORIENTATION.HORIZONTAL) {
						self.__cumulative_horizontal_scroll_offset[_tab] += _s * _amount;
						for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
							self.__children[_i].__dimensions.setScrollOffsetH(_s * _amount);
						}
					}
					else {
						self.__cumulative_vertical_scroll_offset[_tab] += _s * _amount;
						for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
							self.__children[_i].__dimensions.setScrollOffsetV(_s * _amount);
						}
					}
				}
				
				/// @method				resetScroll(_direction)
				/// @description		Resets the scrolling offset to 0 in the indicated direction
				/// @param				{Enum}	_direction	the direction to scroll, as in `UI_ORIENTATION`.				
				/// @return				{UIWidget}	self
				self.resetScroll = function(_direction) {
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					var _cum = _direction == UI_ORIENTATION.HORIZONTAL ? self.__cumulative_horizontal_scroll_offset[_tab] : self.__cumulative_vertical_scroll_offset[_tab];
					self.scroll(_direction, -sign(_cum), abs(_cum));
				}
					
				/// @method				add(_id, [_tab = <current_tab>])
				/// @description		Adds a children Widget to this Widget
				/// @param				{UIWidget}	_id 	The reference to the children Widget to add
				/// @param				{Real}	[_tab]				Tab to get the controls from. <br>
				///													If _tab is a nonnegative number, it will add the children to the specified tab.<br>
				///													If _tab is -1, it will add the children to the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{UIWidget}	The added children Widget. *Note that this does NOT return the current Widget's reference, but rather the children's reference*. This is by design to be able to use `with` in conjunction with this method.
				self.add = function(_id, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					_id.__parent = self;
					_id.__dimensions.setParent(self);
					//array_push(self.__children, _id);
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			array_push(self.__tabs[_tab], _id);					
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	array_push(self.__common_widgets, _id);
					else													array_push(self.__children, _id);
					
					return _id;
				}
			
				/// @method				remove(_ID)
				/// @description		Removes a Widget from the list of children Widget. *Note that this does NOT destroy the Widget*.
				/// @param				{String}	_ID 	The string ID of the children Widget to delete
				/// @param				{Real}	[_tab]				Tab to remove the control from. <br>
				///													If _tab is a nonnegative number, it will add the children to the specified tab.<br>
				///													If _tab is -1, it will add the children to the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{Bool}				Whether the Widget was found (and removed from the list of children) or not.<br>
				///											NOTE: If tab was specified, it will return `false` if the control was not found on the specified tab, regardless of whether it exists on other tabs, or on the common widget-
				self.remove = function(_ID, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					var _array;
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			_array = self.__tabs[_tab];
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	_array = self.__common_widgets;
					else													_array = self.__children;
					
					var _i=0; 
					var _n = array_length(_array);
					var _found = false;
					while (_i<_n && !_found) {
						if (_array[_i].__ID == _ID) {
							array_delete(_array, _i, 1);
							_found = true;						
						}
						else {
							_i++
						}					
					}
					return _found;
				}
			
			
				/// @method				getDescendants()
				/// @description		Gets an array containing all descendants (children, grandchildren etc.) of this Widget.<br>
				///						If widget is a Panel, gets all descendants of the current tab, including common widgets for a Panel
				/// @return				{Array<UIWidget>}	the array of descendant Widget references
				self.getDescendants = function() {
					var _n_children = array_length(self.getChildren());					
					//var _a = array_create(_n_children + _n_common);					
					var _a = [];
					array_copy(_a, 0, self.getChildren(), 0, _n_children); 

					var _n = array_length(_a);
					if (_n == 0) {
						return [];
					}
					else {
						for (var _i=0; _i<_n; _i++) {
							var _b = _a[_i].getDescendants();				
							var _m = array_length(_b);
							for (var _j=0; _j<_m; _j++) {
								array_push(_a, _b[_j]);
							}						
						}
						
						// Copy common widgetts at the end in order to give them preference						
						if (self.__type == UI_TYPE.PANEL) {
							var _n_common = array_length(self.getChildren(-1));
							var _common = self.getChildren(-1);
							for (var _i=0; _i<_n_common; _i++)	array_push(_a, _common[_i]);
						}
						
						return _a;
					}
				}
			
				/// @method				destroy()
				/// @description		Destroys the current widget	and all its children (recursively)
				self.destroy = function() {
					UI.__logMessage("Destroying widget with ID '"+self.__ID+"' from containing Panel '"+self.getContainingPanel().__ID+"' on tab "+string(self.getContainingTab()), UI_MESSAGE_LEVEL.INFO);
					
					// Delete surface
					if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
					
					if (self.__type == UI_TYPE.PANEL) {						
						for (var _i=0, _n=array_length(self.__tabs); _i<_n; _i++) {
							for (var _m=array_length(self.__tabs[_i]), _j=_m-1; _j>=0; _j--) {
								//self.__children[_i].destroy();
								self.__tabs[_i][_j].destroy();
							}
						}
						// Destroy common widgets too
						for (var _n=array_length(self.__common_widgets), _i=_n-1; _i>=0; _i--) {
							self.__common_widgets[_i].destroy();
						}
						self.__close_button = undefined;
						self.__tab_button_control = undefined;
						UI.__destroy_widget(self);
						UI.__currentlyHoveredPanel = noone;
						
						if (self.__modal) {
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(true);
								}
							}
						}
					}
					else {						
						// Delete children
						for (var _n=array_length(self.__children), _i=_n-1; _i>=0; _i--) {
							self.__children[_i].destroy();						
						}
						// Remove from parent panel						
						if (self.__parent.__type == UI_TYPE.PANEL) {
							var _t = self.getContainingTab();
							self.__parent.remove(self.__ID, _t);
						}
						else {
							self.__parent.remove(self.__ID);
						}
						UI.__destroy_widget(self);
					}					
					self.__children = [];					
					UI.__currentlyDraggedWidget = noone;
				}		
			
			#endregion		
		}
	
	#endregion
	
#endregion

#region GM Text Renderer
	
	function text_renderer(_text) constructor {
		self.text = _text;
		self.draw = function(_x, _y) {
			draw_text(_x, _y, self.text);
			return self;
		}
		self.get_text = function() {
			return self.text;
		}
		self.get_width = function() {
			return string_width(self.text);
		}
		self.get_height = function() {
			return string_height(self.text);
		}
		self.get_left = function(_x) {
			return draw_get_halign() == fa_left ? _x : (draw_get_halign() == fa_right ? _x - self.get_width() : _x - self.get_width()/2);
		}
		self.get_right = function(_x) {
			return draw_get_halign() == fa_right ? _x : (draw_get_halign() == fa_left ? _x - self.get_width() : _x + self.get_width()/2);
		}
		self.get_top = function(_y) {
			return draw_get_valign() == fa_top ? _y : (draw_get_valign() == fa_bottom ? _y - self.get_height() : _y - self.get_height()/2);
		}
		self.get_bottom = function(_y) {
			return draw_get_valign() == fa_bottom ? _y : (draw_get_valign() == fa_top ? _y - self.get_height() : _y + self.get_height()/2);
		}
		return self;
	}

#endregion