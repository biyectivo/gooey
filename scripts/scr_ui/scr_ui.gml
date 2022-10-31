#region Helper Enums and Macros
	#macro UI_NUM_CALLBACKS		14
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
		MOUSE_WHEEL_DOWN
	}
	enum UI_TYPE {
		PANEL,
		BUTTON,
		GROUP
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
	
#endregion

#region Helper Functions
	
#endregion

#region Widgets

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
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
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
				if (self.__events_fired[UI_EVENT.LEFT_CLICK])	obj_UI.setPanelFocus(self);
				__generalBuiltInBehaviors();
			}
			
			self.__drag = function() {					
				if (self.__draggable && obj_UI.__drag_action == UI_RESIZE_DRAG.DRAG) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SE) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.__updateChildrenPositions();					
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NE) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_SW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_NW) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_N) {
					self.__dimensions.y = obj_UI.__drag_start_y + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y;
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + obj_UI.__drag_mouse_delta_y - device_mouse_y_to_gui(obj_UI.getMouseDevice()));
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_S) {
					self.__dimensions.height = max(self.__min_height, obj_UI.__drag_start_height + device_mouse_y_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_y);
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_W) {
					self.__dimensions.x = obj_UI.__drag_start_x + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x;
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + obj_UI.__drag_mouse_delta_x - device_mouse_x_to_gui(obj_UI.getMouseDevice()));
					self.__updateChildrenPositions();
				}
				else if (self.__resizable && obj_UI.__drag_action == UI_RESIZE_DRAG.RESIZE_E) {
					self.__dimensions.width = max(self.__min_width, obj_UI.__drag_start_width + device_mouse_x_to_gui(obj_UI.getMouseDevice()) - obj_UI.__drag_mouse_delta_x);
					self.__updateChildrenPositions();
				}
			}
			
		#endregion

		self.__register();
		
		self.setClipsContent(true);
		
		return self;
	}
	
	
	/// @constructor	UIButton(_id, _x, _y, _width, _height, _text, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
	/// @extends		UIWidget
	/// @description	A Button widget, clickable UI widget that performs an action
	/// @param			{String}			_id				The Panel's name, a unique string ID. If the specified name is taken, the panel will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the Panel, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the Panel, **relative to its parent**, according to the _relative_to parameter	
	/// @param			{Real}				_width			The width of the Panel
	/// @param			{Real}				_height			The height of the Panel
	/// @param			{String}			_text			The text to display for the Button
	/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Panel
	/// @param			{Enum}				[_relative_to]	The position relative to which the Panel will be drawn. By default, the top left (TOP_LEFT) <br>
	///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
	/// @return			{UIButton}							self
	function UIButton(_id, _x, _y, _width, _height, _text, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
		#region Private variables
			self.__type = UI_TYPE.BUTTON;
			self.__text = _text;
			self.__text_mouseover = _text;
			self.__text_click = _text;
			self.__sprite = _sprite;
			self.__sprite_mouseover = _sprite;
			self.__sprite_click = _sprite;
			self.__image = 0;
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
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
				
				var _sprite = self.__sprite;
				var _image = self.__image;
				var _text = self.__text;
				if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
					_sprite =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__sprite_click : self.__sprite_mouseover;
					_image =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__image_click : self.__image_mouseover;
					_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
				}
				draw_sprite_stretched(_sprite, _image, _x, _y, _width, _height);
								
				var _x = _x + self.__dimensions.width * obj_UI.getScale()/2;
				var _y = _y + self.__dimensions.height * obj_UI.getScale()/2;
				var _scale = "[scale,"+string(obj_UI.getScale())+"]";
				
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
	
	
	
	
	/// @constructor	UIGroup(_id, _x, _y, _width, _height, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
	/// @extends		UIWidget
	/// @description	A Group widget, packs several widgets on a single, related group
	/// @param			{String}			_id				The Panel's name, a unique string ID. If the specified name is taken, the panel will be renamed and a message will be displayed on the output log.
	/// @param			{Real}				_x				The x position of the Panel, **relative to its parent**, according to the _relative_to parameter
	/// @param			{Real}				_y				The y position of the Panel, **relative to its parent**, according to the _relative_to parameter	
	/// @param			{Real}				_width			The width of the Panel
	/// @param			{Real}				_height			The height of the Panel
	/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Panel
	/// @param			{Enum}				[_relative_to]	The position relative to which the Panel will be drawn. By default, the top left (TOP_LEFT) <br>
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
				var _width = self.__dimensions.width * obj_UI.getScale();
				var _height = self.__dimensions.height * obj_UI.getScale();
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

#region Helper Structs
	function None() {}
	
	
	
	/// @struct					__UIDimensions(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _id)
	/// @description			Private struct that represents the position and size of a particular Widget<br>
	///							Apart from the specified offset_x and offset_y, the resulting struct will also have:<br>
	///							`x` x coordinate of the TOP_LEFT corner of the widget, relative to SCREEN (absolute coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
	///							`y`			y coordinate of the TOP_LEFT corner of the widget, relative to SCREEN (absolute coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
	///							`x_parent`	x coordinate of the TOP_LEFT corner of the widget, relative to PARENT (relative coordinates). These will be used to draw the widget inside other widgets which have the clipContents property enabled (e.g. scrollable panels or other scrollable areas).<br>
	///							`y_parent`	y coordinate of the TOP_LEFT corner of the widget, relative to PARENT (relative coordinates). These will be used to draw the widget inside other widgets which have the clipContents property enabled (e.g. scrollable panels or other scrollable areas).
	///	@param					{Real}		_offset_x		Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
	///														This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
	///	@param					{Real}		_offset_y		Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
	///														This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
	///	@param					{Real}		_width			Width of widget
	///	@param					{Real}		_height			Height of widget		
	///	@param					{Real}		_height			Height of widget		
	///	@param					{UIWidget}	[_parent]	Reference to the parent, or noone
	///	@param					{UIWidget}	_id			ID of the corresponing widget
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
			if (live_call()) return live_result;
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
		self.set = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to=undefined) {
			self.offset_x ??= _offset_x;
			self.offset_y ??= _offset_y;
			self.relative_to ??= _relative_to;
			self.width ??= _width;
			self.height ??= _height;
			// Update screen and relative coordinates with new parent
			self.calculateCoordinates();
		}
		
		// Set parent (and calculate screen/relative coordinates) on creation
		self.setParent(_parent);
	}	
	
	/// @constructor	UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT)
	/// @description	The base class for all ofhter widgets. Should be treated as an
	///					uninstantiable class / template.
	/// @param	{string}	_id					The widget's string ID by which it will be referred as.
	/// @param	{real}		_offset_x			The x offset position relative to its parent, according to the _relative_to parameter
	/// @param	{real}		_offset_y			The y offset position relative to its parent, according to the _relative_to parameter
	/// @param	{real}		_width				The width of the widget
	/// @param	{real}		_height				The height of the widget
	/// @param	{int}		_sprite				The sprite asset to use for rendering
	/// @param	{Enum}		[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
	/// @return	{UIWidget}	self
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
			
			/// @method				setDimensions()
			/// @description		Sets the UIDimensions object for this widget
			/// @param				{Any}	_param	description			
			/// @return				{UIWidget}	self
			static setDimensions = function(_offset_x, _offset_y, _width, _height, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone)	{
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
					obj_UI.__register(self);
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
							draw_surface_part(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * obj_UI.getScale(), self.__dimensions.height * obj_UI.getScale(), self.__dimensions.x, self.__dimensions.y);
						}
					}
				}
			
				static __processEvents = function() {
					array_copy(self.__events_fired_last, 0, self.__events_fired, 0, UI_NUM_CALLBACKS);
					for (var _i=0; _i<UI_NUM_CALLBACKS; _i++)	self.__events_fired[_i] = false;
					if (self.__visible && self.__enabled) {
						self.__events_fired[UI_EVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), self.__dimensions.x, self.__dimensions.y, self.__dimensions.x + self.__dimensions.width * obj_UI.getScale(), self.__dimensions.y + self.__dimensions.height * obj_UI.getScale());
						self.__events_fired[UI_EVENT.LEFT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_left);
						self.__events_fired[UI_EVENT.MIDDLE_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_middle);
						self.__events_fired[UI_EVENT.RIGHT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(obj_UI.getMouseDevice(), mb_right);
						self.__events_fired[UI_EVENT.LEFT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_left);
						self.__events_fired[UI_EVENT.MIDDLE_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_middle);
						self.__events_fired[UI_EVENT.RIGHT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(obj_UI.getMouseDevice(), mb_right);
						self.__events_fired[UI_EVENT.LEFT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left);
						self.__events_fired[UI_EVENT.MIDDLE_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_middle);
						self.__events_fired[UI_EVENT.RIGHT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_right);
						self.__events_fired[UI_EVENT.MOUSE_ENTER] = !self.__events_fired_last[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER];
						self.__events_fired[UI_EVENT.MOUSE_EXIT] = self.__events_fired_last[UI_EVENT.MOUSE_OVER] && !self.__events_fired[UI_EVENT.MOUSE_OVER];
						self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_up();
						self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_down();
					
						// Calculate 3x3 "grid" on the panel, based off on screen coords, that will determine what drag action is fired (move or resize)
						var _w = self.__resize_border_width * obj_UI.getScale();					
						var _x0 = self.__dimensions.x;
						var _x1 = _x0 + _w;
						var _x3 = self.__dimensions.x + self.__dimensions.width * obj_UI.getScale();
						var _x2 = _x3 - _w;
						var _y0 = self.__dimensions.y;
						var _y1 = _y0 + _w;
						var _y3 = self.__dimensions.y + self.__dimensions.height * obj_UI.getScale();
						var _y2 = _y3 - _w;
					
						// Determine mouse cursors for mouseover
						if (self.__events_fired[UI_EVENT.MOUSE_OVER]) {
							var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
							if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y1))			window_set_cursor(cr_size_nwse);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y1))		window_set_cursor(cr_size_nesw);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x1, _y3))		window_set_cursor(cr_size_nesw);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y2, _x3, _y3))		window_set_cursor(cr_size_nwse);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x3, _y1))		window_set_cursor(cr_size_ns);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x2, _y0, _x3, _y3))		window_set_cursor(cr_size_we);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y2, _x3, _y3))		window_set_cursor(cr_size_ns);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x0, _y0, _x1, _y3))		window_set_cursor(cr_size_we);
							else if (point_in_rectangle(device_mouse_x_to_gui(obj_UI.getMouseDevice()), device_mouse_y_to_gui(obj_UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))	window_set_cursor(cr_drag);
						}
					
					
						if (obj_UI.__currentlyDraggedWidget == noone && self.__events_fired[UI_EVENT.LEFT_HOLD])	{
							obj_UI.__currentlyDraggedWidget = self;
							obj_UI.__drag_start_x = self.__dimensions.x;
							obj_UI.__drag_start_y = self.__dimensions.y;
							obj_UI.__drag_start_width = self.__dimensions.width;
							obj_UI.__drag_start_height = self.__dimensions.height;
							obj_UI.__drag_mouse_delta_x = device_mouse_x_to_gui(obj_UI.getMouseDevice());
							obj_UI.__drag_mouse_delta_y = device_mouse_y_to_gui(obj_UI.getMouseDevice());
						
							// Determine drag actions for left hold
							var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
							if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))			obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NW; 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_NE; 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SW; 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_SE; 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_N;	 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_E;	 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_S;	 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))		obj_UI.__drag_action = UI_RESIZE_DRAG.RESIZE_W;	 
							else if (point_in_rectangle(obj_UI.__drag_mouse_delta_x, obj_UI.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	obj_UI.__drag_action = UI_RESIZE_DRAG.DRAG;
							else 	obj_UI.__drag_action = UI_RESIZE_DRAG.NONE;
						
						}
						if (obj_UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(obj_UI.getMouseDevice(), mb_left)) {
							obj_UI.__currentlyDraggedWidget = noone;
							obj_UI.__drag_start_x = -1;
							obj_UI.__drag_start_y = -1;
							obj_UI.__drag_start_width = -1;
							obj_UI.__drag_start_height = -1;
							obj_UI.__drag_mouse_delta_x = -1;
							obj_UI.__drag_mouse_delta_y = -1;
							obj_UI.__drag_action = -1;
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
					obj_UI.__currentlyHoveredPanel = noone;
				}
				obj_UI.destroy_widget(self);
				obj_UI.__currentlyDraggedWidget = noone;				
			}		
			
		#endregion		
	}
	
#endregion