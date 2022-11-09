#region Helper Enums and Macros

	#macro UI_NUM_CALLBACKS		15
	#macro UI_LIBRARY_NAME		"UI2"
	#macro UI_LIBRARY_VERSION	"0.0.1"
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
		TEXTBOX
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
				self.__drag_bar_height = 20;
				self.__resizable = true;			
				self.__resize_border_width = 10;
				self.__title = "";
				self.__title_anchor = UI_RELATIVE_TO.TOP_CENTER;
				self.__close_button = noone;
				self.__close_button_sprite = noone;
				self.__close_button_anchor = UI_RELATIVE_TO.TOP_RIGHT;
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
						self.__close_button.setCallback(UI_EVENT.LEFT_CLICK, function() {						
							self.destroy(); // self is UIPanel here
						});
						self.add(self.__close_button);
					}
					else if (self.__close_button_sprite != noone && _button_sprite != noone) { // Change sprite
						self.__close_button_sprite = _button_sprite;
						self.__close_button.setSprite(_button_sprite);
						self.__close_button.setDimensions(0, 0, sprite_get_width(_button_sprite), sprite_get_height(_button_sprite), "", _button_sprite, self.__close_button_anchor);
					}
					else if (self.__close_button_sprite != noone && _button_sprite == noone) { // Destroy button					
						self.remove(self.__close_button.__ID);
						self.__close_button.destroy();
						self.__close_button = noone;
						self.__close_button_sprite = noone;					
					}				
					return self;
				}
			
			
			#endregion
			#region Methods
				self.__draw = function(_absolute_coords = true) {
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);
					// Title
					if (self.__title != "")	{					
						var _s = scribble(self.__title);
					
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
					if (self.__draggable && UI.__drag_action == UI_RESIZE_DRAG.DRAG) {
						self.__dimensions.x = UI.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y;
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x);
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y);
						self.__updateChildrenPositions();					
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x);
						self.__dimensions.y = UI.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + UI.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SW) {
						self.__dimensions.x = UI.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + UI.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NW) {
						self.__dimensions.x = UI.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y;
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + UI.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + UI.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_N) {
						self.__dimensions.y = UI.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + UI.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_S) {
						self.__dimensions.height = max(self.__min_height, UI.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_W) {
						self.__dimensions.x = UI.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + UI.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_action == UI_RESIZE_DRAG.RESIZE_E) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_mouse_delta_x);
						self.__updateChildrenPositions();
					}
				}
			
			#endregion

			self.setClipsContent(true);
			self.__register();
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
				self.getRawText = function()						{ return self.__text.get_text(); }
			
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
				self.getRawTextMouseover = function()				{ return self.__text_mouseover.get_text(); }	
			
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
				self.getRawTextClick = function()					{ return self.__text_click.get_text(); }
			
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
				self.__draw = function(_absolute_coords = true) {
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
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
					draw_sprite_stretched(_sprite, _image, _x, _y, _width, _height);
								
					var _x = _x + self.__dimensions.width * UI.getScale()/2;
					var _y = _y + self.__dimensions.height * UI.getScale()/2;
					var _scale = "[scale,"+string(UI.getScale())+"]";
				
					scribble(_scale+_text).draw(_x, _y);
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
				self.__draw = function(_absolute_coords = true) {
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);				
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
	
		/// @constructor	UIText(_id, _x, _y, _width, _height, _text, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
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
			#endregion
			#region Setters/Getters
				/// @method				getRawText()
				/// @description		Gets the text of the UIText, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawText = function()						{ return self.__text.get_text(); }
			
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
				self.getRawTextMouseover = function()				{ return self.__text_mouseover.get_text(); }	
			
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
				self.getRawTextClick = function()					{ return self.__text_click.get_text(); }
			
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
			
			#endregion
			#region Methods
				self.__draw = function(_absolute_coords = true) {
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
				
					var _text = self.__text;
					if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
						_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
					}
				
					var _scale = "[scale,"+string(UI.getScale())+"]";
				
					var _s = scribble(_scale+_text);
					self.setDimensions(,,_s.get_width(), _s.get_height());
				
					var _x1 = _s.get_left(_x);
					var _x2 = _s.get_right(_x);
					var _y1 = _s.get_top(_y);
					var _y2 = _s.get_bottom(_y);
					if (self.__background_color != -1)	draw_rectangle_color(_x1, _y1, _x2, _y2, self.__background_color, self.__background_color, self.__background_color, self.__background_color, false);
					if (self.__border_color != -1)		draw_rectangle_color(_x1, _y1, _x2, _y2, self.__border_color, self.__border_color, self.__border_color, self.__border_color, true);
								
					_s.draw(_x, _y);
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
	
		/// @constructor	UICheckbox(_id, _x, _y, _text, _sprite, [_value], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
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
				self.getRawTextTrue = function()					{ return self.__text_true.get_text(); }
			
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
				self.getRawTextFalse = function()					{ return self.__text_false.get_text(); }
			
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
				self.getRawTextMouseover = function()				{ return self.__text_mouseover.get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the button when mouseovered.
				///	@return				{String}	The Scribble text string of the button when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the button when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the button when mouseovered.
				/// @return				{UICheckbox}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
													
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the button when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getImageMouseover()
				/// @description		Gets the image index of the button when mouseovered.		
				/// @return				{Real}	The image index of the button when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the button when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getSpriteTrue()
				/// @description		Gets the sprite ID of the button used for the true state.
				/// @return				{Asset.GMSprite}	The sprite ID of the button used for the true state.
				self.getSpriteTrue = function()				{ return self.__sprite_true; }
			
				/// @method				setSpriteTrue(_sprite)
				/// @description		Sets the sprite to be used for the true state.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteTrue = function(_sprite)			{ self.__sprite_true = _sprite; return self; }
			
				/// @method				getImageTrue()
				/// @description		Gets the image index of the button used for the true state.
				/// @return				{Real}	The image index of the button used for the true state.
				self.getImageTrue = function()					{ return self.__image_true; }
			
				/// @method				setImageTrue(_image)
				/// @description		Sets the image index of the button used for the true state.
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageTrue = function(_image)			{ self.__image_true = _image; return self; }				
				
				/// @method				getSpriteFalse()
				/// @description		Gets the sprite ID of the button used for the false state.	
				/// @return				{Asset.GMSprite}	The sprite ID of the button used for the false state.	
				self.getSpriteFalse = function()				{ return self.__sprite_false; }
			
				/// @method				setSpriteFalse(_sprite)
				/// @description		Sets the sprite to be used for the false state.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteFalse = function(_sprite)			{ self.__sprite_false = _sprite; return self; }
			
				/// @method				getImageFalse()
				/// @description		Gets the image index of the button used for the false state.		
				/// @return				{Real}	The image index of the button  used for the false state.	
				self.getImageFalse = function()					{ return self.__image_false; }
			
				/// @method				setImageFalse(_image)
				/// @description		Sets the image index of the button used for the false state.	
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
					if (_value != self.__value)	self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__value = _value; return self;
				}
				
				/// @method				toggle()
				/// @description		Toggles the value of the checkbox
				/// @return				{UICheckbox}	self
				self.toggle = function() { 
					self.__callbacks[UI_EVENT.VALUE_CHANGED]();
					self.__value = !self.__value; return self;
				}
								
			#endregion
			#region Methods
				self.__draw = function(_absolute_coords = true) {
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
					var _width = (self.__value ? sprite_get_width(self.__sprite_true) : sprite_get_width(self.__sprite_false)) * UI.getScale();
					var _height = (self.__value ? sprite_get_height(self.__sprite_true) : sprite_get_height(self.__sprite_false)) * UI.getScale();
				
					var _sprite = self.__value ? self.__sprite_true : self.__sprite_false;
					var _image = self.__value ? self.__image_true : self.__image_false;
					var _text = self.__value ? self.__text_true : self.__text_false;
					
					// Deleted mouseover/click text/sprites
					
					draw_sprite_stretched(_sprite, _image, _x, _y, _width, _height);
								
					var _x = _x + _width;
					var _y = _y + _height/2;
					
					var _scale = "[scale,"+string(UI.getScale())+"]";				
					var _s = scribble(_scale+_text);
					
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
					// WARNING: assuming absolute coords! Theoretically there are no more relative coords, but who knows...
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
				
				self.__draw = function(_absolute_coords = true) {
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
										
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
					
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
					
					draw_sprite_stretched(self.__sprite_base, self.__image_base, _x, _y, _width_base, _height_base);
					draw_sprite(self.__sprite_handle, self.__image_handle, _handle.x, _handle.y);

					self.setDimensions(,, _width, _height);
					
					if (self.__show_min_max_text) {
						var _smin = scribble(self.__text_format + string(self.__min_value));
						var _smax = scribble(self.__text_format + string(self.__max_value));												
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
						var _stxt = scribble(self.__text_format + string(self.__value));
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
							self.__text = self.__max_chars == 0 ? _text : string_copy(_text, 1, self.__max_chars);
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
						else if (keyboard_lastkey != vk_delete)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos+1;
					}
					else {
						if (keyboard_lastkey == vk_home)		self.__cursor_pos = 0;
						else if (keyboard_lastkey == vk_end)	self.__cursor_pos = -1;
					}
				}
				
				self.__draw = function(_absolute_coords = true) {
					// Clean the click command
					if ((keyboard_check_pressed(vk_enter) && !self.__multiline) && UI.__textbox_editing_ref == self && !self.__read_only) {
						UI.__textbox_editing_ref = noone;
						self.__cursor_pos = -1;
						keyboard_string = "";
					}
					
					var _x = _absolute_coords ? self.__dimensions.x : self.__dimensions.relative_x;
					var _y = _absolute_coords ? self.__dimensions.y : self.__dimensions.relative_y;
					var _width = self.__dimensions.width * UI.getScale();					
					var _height = self.__dimensions.height * UI.getScale();
															
					var _text_to_display = (self.__text == "" && UI.__textbox_editing_ref != self) ? self.__placeholder_text : (self.__mask_text ? string_repeat(self.__mask_char, string_length(self.__text)) : self.__text);
					var _cursor = (UI.__textbox_editing_ref == self ? "[blink][c_gray]|[/blink]"+self.getTextFormat() : "");
					var _text_with_cursor = self.__cursor_pos == -1 ? _text_to_display + _cursor : string_copy(_text_to_display, 1, self.__cursor_pos)+_cursor+string_copy(_text_to_display, self.__cursor_pos+1, string_length(_text_to_display));
					
					var _n = max(1, string_length(_text_to_display));
					var _avg_width = scribble(self.__text_format + "e").get_width();
					var _letter_height = scribble(self.__text_format + "|").get_height();
					var _s = scribble(self.__text_format + _text_with_cursor);
										
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
						var _test = scribble(string_copy(_text_to_display, 1, self.__cursor_pos)).get_width();
						var _cursor_left_of_textbox = (_test < _offset);
						while (_cursor_left_of_textbox) {
							_offset -= 2*_avg_width;
							_cursor_left_of_textbox = (_test < _offset);
						}
					}
					
					
					draw_sprite_stretched(self.__sprite, self.__image, _x, _y, _width, _height);
					
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

#endregion

#region Helper Structs
	function None() {}
	
	
	
	/// @struct					__UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _id)
	/// @description			Private struct that represents the position and size of a particular Widget<br>
	///							Apart from the specified offset_x and offset_y, the resulting struct will also have:<br>
	///							`x`			x coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
	///							`y`			y coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
	///							`x_parent`	x coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).<br>
	///							`y_parent`	y coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).
	///	@param					{Real}		_offset_x		Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
	///														This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
	///	@param					{Real}		_offset_y		Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
	///														This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
	///	@param					{Real}		_width			Width of widget
	///	@param					{Real}		_height			Height of widget		
	///	@param					{Real}		_height			Height of widget		
	///	@param					{UIWidget}	[_parent]		Reference to the parent, or noone
	///	@param					{UIWidget}	_id				ID of the corresponing widget
	function __UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _id) constructor {
		self.widget_id = _id;
		self.relative_to = _relative_to;
		self.offset_x = _offset_x;
		self.offset_y = _offset_y;
		self.width = _width;
		self.height = _height;
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
		
		// Set parent (and calculate screen/relative coordinates) on creation
		self.setParent(_parent);
	}	
	
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
			self.__dimensions = new __UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to, noone, self);
			self.__sprite = _sprite;
			self.__image = 0;
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
		#endregion
		#region Setters/Getters
			/// @method				getID()
			/// @description		Getter for the widget's string ID
			/// @returns			{string} The widget's string ID
			static getID = function()					{ return self.__ID; }
			
			/// @method				getType()
			/// @description		Getter for the widget's type
			/// @returns			{Enum}	The widget's type, according to the UI_TYPE enum			
			static getType = function()					{ return self.__type; }
			
			/// @method				getDimensions()
			/// @description		Gets the UIDimensions object for this widget
			/// @returns			{UIDimensions}	The dimensions object. See [`UIDimensions`](#__UIDimensions).
			static getDimensions = function()			{ return self.__dimensions; }
			
			/// @method						setDimensions()
			/// @description				Sets the UIDimensions object for this widget, with optional parameters.
			/// @param	{Real}				[_offset_x]			The x offset position relative to its parent, according to the _relative_to parameter
			/// @param	{Real}				[_offset_y]			The y offset position relative to its parent, according to the _relative_to parameter
			/// @param	{Real}				[_width]			The width of the widget
			/// @param	{Real}				[_height]			The height of the widget			
			/// @param	{Enum}				[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
			/// @param	{UIWidget}			[_parent]			Parent Widget reference
			/// @return						{UIWidget}	self
			static setDimensions = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to = undefined, _parent = undefined)	{
				self.__dimensions.set(_offset_x, _offset_y, _width, _height, _relative_to, _parent);
				return self;
			}
			
			/// @method				getSprite(_sprite)
			/// @description		Get the sprite ID to be rendered
			/// @return				{Asset.GMSprite}	The sprite ID
			static getSprite = function()				{ return self.__sprite; }
			
			/// @method				setSprite(_sprite)
			/// @description		Sets the sprite to be rendered
			/// @param				{Asset.GMSprite}	_sprite		The sprite ID
			/// @return				{UIWidget}	self
			static setSprite = function(_sprite)		{ self.__sprite = _sprite; return self; }
			
			/// @method				getImage()
			/// @description		Gets the image index of the Widget
			/// @return				{Real}	The image index of the Widget
			static getImage = function()				{ return self.__image_; }
			
			/// @method				setImage(_image)
			/// @description		Sets the image index of the Widget
			/// @param				{Real}	_image	The image index
			/// @return				{UIWidget}	self
			static setImage = function(_image)			{ self.__image = _image; return self; }
			
			/// @method				getCallback(_callback_type)
			/// @description		Gets the callback function for a specific callback type, according to the `UI_EVENT` enum
			/// @param				{Enum}	_callback_type	The callback type
			/// @return				{Function}	the callback function
			static getCallback = function(_callback_type)				{ return self.__callbacks[_callback_type]; }
			
			/// @method				setCallback(_callback_type, _function)
			/// @description		Sets a callback function for a specific event
			/// @param				{Enum}	_callback_type	The callback type, according to `UI_EVENT` enum
			/// @param				{Function}	_function	The callback function to assign
			/// @return				{UIWidget}	self
			static setCallback = function(_callback_type, _function)	{ self.__callbacks[_callback_type] = _function; return self; }
			
			/// @method				getParent()
			/// @description		Gets the parent reference of the Widget (also a Widget)			
			/// @return				{UIWidget}	the parent reference
			static getParent = function()				{ return self.__parent; }
			
			/// @method				setParent(_parent_id)
			/// @description		Sets the parent of the Widget. Also calls the `setParent()` method of the corresponding `UIDimensions` struct to recalculate coordinates.
			/// @param				{UIWidget}	_parent_id	The reference to the parent Widget
			/// @return				{UIWidget}	self
			static setParent = function(_parent_id)		{ 
				self.__parent = _parent_id;
				self.__dimensions.setParent(_parent_id);
				return self;
			}
			
			/// @method				getChildren()
			/// @description		Gets the array containing all children of this Widget
			/// @return				{Array<UIWidget>}	the array of children Widget references
			static getChildren = function()				{ return self.__children; }
			
			/// @method				setChildren(_children)
			/// @description		Sets the children Widgets to a new array of Widget references
			/// @param				{Array<UIWidget>}	_children	The array containing the references of the children Widgets
			/// @return				{UIWidget}	self
			static setChildren = function(_children)	{ self.__children = _children; return self; }
			
			/// @method				getVisible()
			/// @description		Gets the visible state of a Widget
			/// @return				{Bool}	whether the Widget is visible or not
			static getVisible = function()				{ return self.__visible; }
			
			/// @method				setVisible(_visible)
			/// @description		Sets the visible state of a Widget
			/// @param				{Bool}	_visible	Whether to set visibility to true or false			
			/// @return				{UIWidget}	self
			static setVisible = function(_visible)		{ self.__visible = _visible; return self; }
			
			/// @method				getEnabled()
			/// @description		Gets the enabled state of a Widget
			/// @return				{Bool}	whether the Widget is enabled or not
			static getEnabled = function()				{ return self.__enabled; }
			
			/// @method				setEnabled(_enabled)
			/// @description		Sets the enabled state of a Widget
			/// @param				{Bool}	_enabled	Whether to set enabled to true or false			
			/// @return				{UIWidget}	self			
			static setEnabled = function(_enabled)		{ self.__enabled = _enabled; return self; }
			
			/// @method				getDraggable()
			/// @description		Gets the draggable state of a Widget
			/// @return				{Bool}	whether the Widget is draggable or not
			static getDraggable = function()			{ return self.__draggable; }
			
			/// @method				setDraggable(_draggable)
			/// @description		Sets the draggable state of a Widget
			/// @param				{Bool}	_draggable	Whether to set draggable to true or false			
			/// @return				{UIWidget}	self
			static setDraggable = function(_draggable)	{ self.__draggable = _draggable; return self; }
			
			/// @method				getResizable()
			/// @description		Gets the resizable state of a Widget
			/// @return				{Bool}	whether the Widget is resizable or not
			static getResizable = function()			{ return self.__resizable; }
			
			/// @method				setResizable(_resizable)
			/// @description		Sets the resizable state of a Widget
			/// @param				{Bool}	_resizable	Whether to set resizable to true or false			
			/// @return				{UIWidget}	self
			static setResizable = function(_resizable)	{ self.__resizable = _resizable; return self; }
			
			/// @method				getResizeBorderWidth()
			/// @description		Gets the width of the border of a Widget that enables resizing
			/// @return				{Real}	the width of the border in px
			static getResizeBorderWidth = function()		{ return self.__resize_border_width; }
			
			/// @method				setResizeBorderWidth(_resizable)
			/// @description		Sets the resizable state of a Widget
			/// @param				{Real}	_border_width	The width of the border in px
			/// @return				{UIWidget}	self
			static setResizeBorderWidth = function(_border_width)		{ self.__resize_border_width = _border_width; return self; }
			
			/// @method				getClipsContent()
			/// @description		Gets the Widget's masking/clipping state
			/// @return				{Bool}	Whether the widget clips its content or not.
			static getClipsContent = function()			{ return self.__clips_content; }
			
			/// @method				setClipsContent(_clips)
			/// @description		Sets the Widget's masking/clipping state.<br>
			///						Note this method automatically creates/frees the corresponding surfaces.
			/// @param				{Bool}	_clips	Whether the widget clips its content or not.
			/// @return				{UIWidget}	self
			static setClipsContent = function(_clips) {
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
		#endregion
		#region Methods
			
			#region Private
			
				static __register = function() {
					UI.__register(self);
				}
			
				static __updateChildrenPositions = function() {
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].__dimensions.calculateCoordinates();
						self.__children[_i].__updateChildrenPositions();
					}
				}
			
				static __render = function(_absolute_coords = true) {
					if (self.__visible) {
						// Draw this widget
						self.__draw(_absolute_coords);
					
						if (self.__clips_content) {
							if (!surface_exists(self.__surface_id)) self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
							surface_set_target(self.__surface_id);
							draw_clear_alpha(c_black, 0);
						}
										
						// Render children - if the widget clips content, then render them with relative coordinates; otherwise, render them with absolute coordinates
						for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].__render(true);
					
						if (self.__clips_content) {						
							surface_reset_target();
							// The surface needs to be drawn with screen coords
							draw_surface_part(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * UI.getScale(), self.__dimensions.height * UI.getScale(), self.__dimensions.x, self.__dimensions.y);
						}
					}
				}
			
				static __processEvents = function() {
					array_copy(self.__events_fired_last, 0, self.__events_fired, 0, UI_NUM_CALLBACKS);
					for (var _i=0; _i<UI_NUM_CALLBACKS; _i++)	self.__events_fired[_i] = false;
					if (self.__visible && self.__enabled) {
						self.__events_fired[UI_EVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), self.__dimensions.x, self.__dimensions.y, self.__dimensions.x + self.__dimensions.width * UI.getScale(), self.__dimensions.y + self.__dimensions.height * UI.getScale());
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
							if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y1))			window_set_cursor(cr_size_nwse);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y1))		window_set_cursor(cr_size_nesw);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x1, _y3))		window_set_cursor(cr_size_nesw);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y2, _x3, _y3))		window_set_cursor(cr_size_nwse);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x3, _y1))		window_set_cursor(cr_size_ns);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y3))		window_set_cursor(cr_size_we);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x3, _y3))		window_set_cursor(cr_size_ns);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y3))		window_set_cursor(cr_size_we);
							else if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))	window_set_cursor(cr_drag);
						}
					
					
						if (UI.__currentlyDraggedWidget == noone && self.__events_fired[UI_EVENT.LEFT_HOLD])	{
							UI.__currentlyDraggedWidget = self;
							UI.__drag_start_x = self.__dimensions.x;
							UI.__drag_start_y = self.__dimensions.y;
							UI.__drag_start_width = self.__dimensions.width;
							UI.__drag_start_height = self.__dimensions.height;
							UI.__drag_mouse_delta_x = device_mouse_x_to_gui(UI.getMouseDevice());
							UI.__drag_mouse_delta_y = device_mouse_y_to_gui(UI.getMouseDevice());
						
							// Determine drag actions for left hold
							var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
							if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))			UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NW; 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NE; 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SW; 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SE; 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_N;	 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_E;	 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_S;	 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))		UI.__drag_action = UI_RESIZE_DRAG.RESIZE_W;	 
							else if (point_in_rectangle(UI.__drag_mouse_delta_x, UI.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	UI.__drag_action = UI_RESIZE_DRAG.DRAG;
							else 	UI.__drag_action = UI_RESIZE_DRAG.NONE;
						
						}
						if (UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(UI.getMouseDevice(), mb_left)) {
							UI.__currentlyDraggedWidget = noone;
							UI.__drag_start_x = -1;
							UI.__drag_start_y = -1;
							UI.__drag_start_width = -1;
							UI.__drag_start_height = -1;
							UI.__drag_mouse_delta_x = -1;
							UI.__drag_mouse_delta_y = -1;
							UI.__drag_action = -1;
							window_set_cursor(cr_default);
						}
					}
				}
				
				static __builtInBehavior = function(_process_array = array_create(UI_NUM_CALLBACKS, true)) {
					if (_process_array[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER]) 		self.__callbacks[UI_EVENT.MOUSE_OVER]();
					if (_process_array[UI_EVENT.LEFT_CLICK] && self.__events_fired[UI_EVENT.LEFT_CLICK]) 		self.__callbacks[UI_EVENT.LEFT_CLICK]();
					if (_process_array[UI_EVENT.MIDDLE_CLICK] && self.__events_fired[UI_EVENT.MIDDLE_CLICK]) 	self.__callbacks[UI_EVENT.MIDDLE_CLICK]();
					if (_process_array[UI_EVENT.RIGHT_CLICK] && self.__events_fired[UI_EVENT.RIGHT_CLICK]) 		self.__callbacks[UI_EVENT.RIGHT_CLICK]();
					if (_process_array[UI_EVENT.LEFT_HOLD] && self.__events_fired[UI_EVENT.LEFT_HOLD]) 		self.__callbacks[UI_EVENT.LEFT_HOLD]();
					if (_process_array[UI_EVENT.MIDDLE_HOLD] && self.__events_fired[UI_EVENT.MIDDLE_HOLD]) 		self.__callbacks[UI_EVENT.MIDDLE_HOLD]();
					if (_process_array[UI_EVENT.RIGHT_HOLD] && self.__events_fired[UI_EVENT.RIGHT_HOLD]) 		self.__callbacks[UI_EVENT.RIGHT_HOLD]();
					if (_process_array[UI_EVENT.LEFT_RELEASE] && self.__events_fired[UI_EVENT.LEFT_RELEASE]) 	self.__callbacks[UI_EVENT.LEFT_RELEASE]();
					if (_process_array[UI_EVENT.MIDDLE_RELEASE] && self.__events_fired[UI_EVENT.MIDDLE_RELEASE]) 	self.__callbacks[UI_EVENT.MIDDLE_RELEASE]();
					if (_process_array[UI_EVENT.RIGHT_RELEASE] && self.__events_fired[UI_EVENT.RIGHT_RELEASE]) 	self.__callbacks[UI_EVENT.RIGHT_RELEASE]();
					if (_process_array[UI_EVENT.MOUSE_ENTER] && self.__events_fired[UI_EVENT.MOUSE_ENTER]) 		self.__callbacks[UI_EVENT.MOUSE_ENTER]();
					if (_process_array[UI_EVENT.MOUSE_EXIT] && self.__events_fired[UI_EVENT.MOUSE_EXIT]) 		self.__callbacks[UI_EVENT.MOUSE_EXIT]();
					if (_process_array[UI_EVENT.MOUSE_WHEEL_UP] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP]) 	self.__callbacks[UI_EVENT.MOUSE_WHEEL_UP]();
					if (_process_array[UI_EVENT.MOUSE_WHEEL_DOWN] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN])	self.__callbacks[UI_EVENT.MOUSE_WHEEL_DOWN]();					
					// Handle Value Changed event on the UI object
				}	
			
			#endregion
			
			
			/// @method				add(_id)
			/// @description		Adds a children Widget to this Widget
			/// @param				{UIWidget}	_id 	The reference to the children Widget to add
			/// @return				{UIWidget}	The children Widget. *Note that this does NOT return the current Widget's reference, but rather the children's reference*. This is by design to be able to use `with` in conjunction with this method.
			static add = function(_id) {
				_id.__parent = self;
				_id.__dimensions.setParent(self);
				array_push(self.__children, _id);
				return _id;
			}
			
			/// @method				remove(_id)
			/// @description		Removes a Widget from the list of children Widget. *Note that this does NOT destroy the Widget*.
			/// @param				{UIWidget}	_id 	The reference to the children Widget to delete
			/// @return				{Bool}	Whether the Widget was found (and removed from the list of children) or not
			static remove = function(_id) {
				var _i=0; 
				var _n = array_length(self.__children);
				var _found = false;
				while (_i<_n && !_found) {
					if (self.__children[_i].__ID == _id) {
						array_delete(self.__children, _i, 1);
						_found = true;						
					}
					else {
						_i++
					}					
				}
				return _found;
			}
			
			
			/// @method				getDescendants()
			/// @description		Gets an array containing all descendants (children, grandchildren etc.) of this Widget
			/// @return				{Array<UIWidget>}	the array of descendant Widget references
			static getDescendants = function() {
				var _a = [];
				array_copy(_a, 0, self.getChildren(), 0, array_length(self.getChildren()));
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
					return _a;
				}
			}
			
			/// @method				destroy()
			/// @description		Destroys the current widget	and all its children (recursively)
			static destroy = function() {
				if (self.__type == UI_TYPE.PANEL) {
					if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].destroy();
					}
					UI.__currentlyHoveredPanel = noone;
				}
				UI.__destroy_widget(self);
				UI.__currentlyDraggedWidget = noone;				
			}		
			
		#endregion		
	}
	
#endregion