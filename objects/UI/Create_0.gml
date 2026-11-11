/// @feather ignore all
/// GMLDocMaker trick
/// @struct						UI
/// @description				UI Manager object

surface_depth_disable(UI_ENABLE_DEPTH);

#region Private variables

	self.__scale = 1;
	self.__scale_tag = "[scale,1]";	// Scribble tag for the current scale (rebuilt only when the scale changes)
	self.__mouse_device = 0;
	self.__widgets = [];
	self.__panels = [];
	self.__currentlyHoveredPanel = noone;
	self.__currentlyHoveredWidget = noone;
	self.__currentlyDraggedWidget = noone;
	self.__drag_data = {
		__drag_action: -1,
		__drag_start_x: -1,
		__drag_start_y: -1,
		__drag_mouse_delta_x: -1,
		__drag_mouse_delta_y: -1,
		__drag_specific_start_x: -1,
		__drag_specific_start_y: -1,
		__drag_specific_start_width: -1,
		__drag_specific_start_height: -1
	}
	self.__UI_interaction = false;
	self.__logMessageLevel = UI_LOG_MESSAGE_LEVEL;
	self.__textbox_editing_ref = noone;
	self.__camera_id = undefined;
	self.__log_count = 0;
	self.__id_map = {};
	// Input snapshot, sampled ONCE per frame through the input seam (widgets read this instead of calling the seam ~13 times each)
	self.__input = {mx: 0, my: 0, pressed: [false, false, false, false], down: [false, false, false, false], released: [false, false, false, false], wheel_up: false, wheel_down: false};
	self.__pending_exit = [];	// widgets whose MOUSE_EXIT flag was set this frame (so the exit pass does not scan every widget)
	self.__cursor_requested = undefined;
	self.__cursor_applied = undefined;
		
#endregion

#region Setters/Getters and Methods

	#region Private
	
		self.__sampleInput = function() {
				var _d = self.getMouseDevice();
				var _in = self.__input;
				_in.mx = __gooey_mouse_x(_d);
				_in.my = __gooey_mouse_y(_d);
				for (var _b=mb_left; _b<=mb_middle; _b++) {
					_in.pressed[_b] = __gooey_mouse_pressed(_d, _b);
					_in.down[_b] = __gooey_mouse_down(_d, _b);
					_in.released[_b] = __gooey_mouse_released(_d, _b);
				}
				_in.wheel_up = __gooey_wheel_up();
				_in.wheel_down = __gooey_wheel_down();
			}

			self.__processEvents = function() {
				self.__UI_interaction = false;
				self.__sampleInput();

			// Drag
			if (UI.__currentlyDraggedWidget != noone && UI.__currentlyDraggedWidget.__draggable) {
				self.__UI_interaction = true;
				UI.__currentlyDraggedWidget.__drag();
				// Handle panel drag			
				if (UI.__currentlyDraggedWidget.__type == UI_TYPE.PANEL) {
					// Process common widget events (and descendants)
					var _common = UI.__currentlyDraggedWidget.__common_widgets;
					for (var  _n=array_length(_common), _i=_n-1; _i>=0; _i--) { 
						_common[_i].__processEvents();					
						var _descendants = _common[_i].__getDescendantsCached();
						for (var _m=array_length(_descendants), _j=_m-1; _j>=0; _j--) {
							_descendants[_j].__processEvents();
						}
					}
				
					// Determine common widget to execute built-in behaviors and callbacks depending on the processed events
					// Mainly needed to process buttons like close button when they are over the drag bar of the panel
					// Candidates are the common widgets AND their descendants (e.g. the tab buttons inside the tab group), deepest last
					var _candidates = [];
					for (var _k=0, _c=array_length(_common); _k<_c; _k++) {
						array_push(_candidates, _common[_k]);
						var _sub = _common[_k].__getDescendantsCached();
						for (var _l=0, _s=array_length(_sub); _l<_s; _l++)	array_push(_candidates, _sub[_l]);
					}
					_common = _candidates;
					_n = array_length(_common);
					_i=_n-1;
					var _mouse_over = false;
					while (_i>=0 && !_mouse_over) {
						if (_common[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
							_mouse_over = true;
						}
						else {
							_i--;
						}
					}
					if (_mouse_over) {
						self.__currentlyHoveredWidget = _common[_i];
						// Override drag action of panel
						if (_common[_i].__events_fired[UI_EVENT.LEFT_HOLD] && _common[_i].__dragCondition())	{
							_common[_i].__dragStart();
						}
						_common[_i].__builtInBehavior();
					}
					else {
						self.__currentlyHoveredWidget = noone;
					}
				
				}			
			}
			else {
				if (UI_MANAGE_CURSORS)	UI.__setUICursor(UI_CURSOR_DEFAULT);
				
				// Check for mouseover on all enabled and visible panels
				var _n = array_length(self.__panels);
				for (var _i = _n-1; _i>=0; _i--) {
					//if (self.__panels[_i].__visible && self.__panels[_i].__enabled)		self.__panels[_i].__processMouseover();
					self.__panels[_i].__processMouseover();
				}
		
				// Determine topmost mouseovered panel
				var _last_hovered_panel = self.__currentlyHoveredPanel;
			
				var _n = array_length(self.__panels);
				_i=_n-1;
				var _mouse_over = false;
				while (_i>=0 && !_mouse_over) {
					if (self.__panels[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
						_mouse_over = true;
					}
					else {
						_i--;
					}
				}
				self.__currentlyHoveredPanel = _i >= 0 ? _i : -1;
				
				// Hack to process mouse events of dropdowns outside panels (original by @ccxnnr)
				// Modified so only panels that do not clip contents behave like this
				if (self.__currentlyHoveredPanel == -1) {
					for (var _i=_n-1; _i>=0; _i--) {
						var _panel = self.__getPanelByIndex(_i);
						var _descendants = _panel.__getDropdownsCached();
						for (var _m=array_length(_descendants), _j=_m-1; _j>=0; _j--) {
							var _widget = _descendants[_j];
							if (!_widget.getContainingPanel().getClipsContent()) {
								self.__currentlyHoveredPanel = _i;
								break;
							}
						}
					}
				}
				
				if (self.__currentlyHoveredPanel != -1) {
					self.__UI_interaction = true;
					var _panel = self.__getPanelByIndex(self.__currentlyHoveredPanel);			
							
					// Get topmost panel, get all its descendants				
					var _descendants = _panel.__getDescendantsCached();

					// Process panel events- check if drag is active. If it is, give preference to Panel drag action; if not, clear panel events and proceed
					_panel.__processEvents();
					if (self.__currentlyDraggedWidget == _panel && self.__drag_data.__drag_action != UI_RESIZE_DRAG.NONE) {		
						//show_debug_message("  Panel "+self.__currentlyDraggedWidget.__ID+" with drag behavior "+string(self.__drag_data.__drag_action));
						_panel.__builtInBehavior();
					}
					else {					
						//_panel.__clearEvents(false);
						// Process events on all enabled and visible children widgets
						var _n = array_length(_descendants);
						for (var _i = _n-1; _i>=0; _i--)	_descendants[_i].__processEvents();
					
						// Determine children widget to execute built-in behaviors and callbacks depending on the processed events
						_i=_n-1;
						var _mouse_over = false;
						while (_i>=0 && !_mouse_over) {
							if (_descendants[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
								_mouse_over = true;
							}
							else {
								_i--;
							}
						}
						if (_mouse_over) {						
							self.__currentlyHoveredWidget = _descendants[_i];
							// Override drag action of panel
							if (_descendants[_i].__events_fired[UI_EVENT.LEFT_HOLD] && _descendants[_i].__dragCondition())	{
								_descendants[_i].__dragStart();						
							}
							_descendants[_i].__builtInBehavior();
						}
						else {
							self.__currentlyHoveredWidget = noone;
							_panel.__builtInBehavior();	
						}
					}
				}
				else {
					// Clear widget events on panel exit
					if (_last_hovered_panel != noone) {
						var _panel = self.__getPanelByIndex(_last_hovered_panel);
						if (_panel != noone) {
							var _descendants = _panel.__getDescendantsCached();
							for (var _i=0, _n=array_length(_descendants); _i<_n; _i++) {
								var _widget = _descendants[_i];
								var _was_mouse_over = _widget.__events_fired[UI_EVENT.MOUSE_OVER];
								_widget.__clearEvents();
								if (_was_mouse_over) {
									_widget.__events_fired[UI_EVENT.MOUSE_EXIT] = 1;
									array_push(self.__pending_exit, _widget);
								}
							}
						}
					}
					self.__currentlyDraggedWidget = noone;
					self.__currentlyHoveredWidget = noone;
				}
			
			
				// Process mouse exit FOR ALL widgets, not just current panel
				// Iterate over a snapshot, since callbacks may destroy widgets
				var _all_widgets = self.__pending_exit;
				self.__pending_exit = [];
				for (var _i=0, _n=array_length(_all_widgets); _i<_n; _i++) {
					var _w = _all_widgets[_i];
					if (!_w.__destroyed && _w.__events_fired[UI_EVENT.MOUSE_EXIT]) {
						_w.__events_fired[UI_EVENT.MOUSE_EXIT] = false;
						_w.__callbacks[UI_EVENT.MOUSE_EXIT]();
					}
				}
		
				// Handle text string for textboxes
				if (self.__textbox_editing_ref != noone) {
			
					var _actually_edit = false;
			
					// Cursor
					var _c = self.__textbox_editing_ref.getCursorPos();
					var _current_text = self.__textbox_editing_ref.getText();
					var _len = string_length(_current_text);
			
			
						
					// Check if click was done outside all textboxes
					if (__gooey_mouse_pressed(self.getMouseDevice(), mb_left)) {
						var _click_outside_all = true;
						var _i=0, _n=array_length(self.__widgets);
						while (_i<_n && _click_outside_all) {					
							var _widget = self.__widgets[_i];
							if (_widget.__type == UI_TYPE.TEXTBOX) {
								_click_outside_all = _click_outside_all && !_widget.__events_fired[UI_EVENT.LEFT_CLICK];
							}
							_i++;
						}
						if (_click_outside_all) {
							self.__textbox_editing_ref.setCursorPos(-1);
							self.__textbox_editing_ref = noone;
							keyboard_string = "";
						}
						else {					
							_actually_edit = true;
						}
					}
					else {			
						_actually_edit = true;
					}
			
					if (_actually_edit) { // Capture text from keyboard at cursor position
						var _tb = self.__textbox_editing_ref;
						var _c_pos = (keyboard_lastkey == vk_delete) ? _c+2 : _c+1;
						keyboard_string = self.__keep_allowed_chars(keyboard_string, _tb.getAllowLowercaseLetters(), _tb.getAllowUppercaseLetters(), _tb.getAllowSpaces(), _tb.getAllowDigits(), _tb.getAllowSymbols(), _tb.getSymbolsAllowed() );
						// keyboard_string is limited to 1024 chars: it only holds the tail of the text before the cursor, the head is kept in the textbox
						var _before_cursor = _tb.__kbd_head + keyboard_string;
						_tb.setText(_c == -1 ? _before_cursor : _before_cursor + string_copy(_current_text, _c_pos, _len));
						_tb.__syncKeyboard();
					}
				}
			}
		
			// An open modal panel blocks the whole screen: nothing may reach the game
			if (!self.__UI_interaction) {
				for (var _i=array_length(self.__panels)-1; _i>=0; _i--) {
					if (self.__panels[_i].__modal && self.__panels[_i].__visible) {
						self.__UI_interaction = true;
						break;
					}
				}
			}
		
			// Close open dropdowns when clicking elsewhere or pressing Escape
			var _escape = __gooey_key_pressed(vk_escape);
			if (_escape || __gooey_mouse_pressed(self.getMouseDevice(), mb_left)) {
				for (var _i=0, _n=array_length(self.__widgets); _i<_n; _i++) {
					var _w = self.__widgets[_i];
					if (_w.__type == UI_TYPE.DROPDOWN && _w.__dropdown_active && (_escape || !_w.__events_fired[UI_EVENT.LEFT_CLICK]))	_w.__dropdown_active = false;
				}
			}
		
			// Check drag end - Currently dragged widget might be noone now because of panel close
			if (UI.__currentlyDraggedWidget != noone)	UI.__currentlyDraggedWidget.__isDragEnd();

			// Apply the cursor requested during this frame (once, and only if it changed)
			if (UI_MANAGE_CURSORS)	self.__applyUICursor();
		}
	
	
		// The cursor is only *requested* while events are processed (it is reset to the default at the start of every frame and
		// widgets then request hand/resize/drag cursors). The request is applied to the OS once, at the end of the frame, and only
		// if it changed. Applying it eagerly made the OS cursor switch default -> hand -> default every frame (flicker), and with a
		// sprite cursor it also toggled the native cursor between cr_none and the arrow.
		self.__setUICursor = function(_cursor) {
			self.__cursor_requested = _cursor;
		}

		self.__applyUICursor = function() {
			var _cursor = self.__cursor_requested;
			if (_cursor == self.__cursor_applied)	return;
			self.__cursor_applied = _cursor;
			if (_cursor > 0) {	// All cr_ constants are negative except cr_default, which is 0 - and this can coincide with a sprite index.
				window_set_cursor(cr_none);
				cursor_sprite = _cursor;
			}
			else {
				window_set_cursor(_cursor);
				cursor_sprite = -1;
			}
		}
	
		self.__logMessage = function(_msg, _lvl)	{ 
			var _lvls = ["INFO", "WARNING", "ERROR", "NOTICE"];
			if (_lvl >= self.__logMessageLevel) {
				self.__log_count++;
				show_debug_message("["+UI_LIBRARY_NAME+"] <"+ _lvls[_lvl]+"> "+_msg);
			}
		}
		
		self.__getPanelByIndex = function(_idx)		{ return _idx >= 0 && _idx < array_length(self.__panels) ? self.__panels[_idx] : noone; }
		
		self.__getPanelIndex = function(_ID) {
			var _i = 0;
			var _n = array_length(self.__panels);
			var _found = false;
			while (_i<_n && !_found) {
				if (self.__panels[_i].getID() == _ID) {
					_found = true;
				}
				else {
					_i++;
				}
			}
			return _found ? _i : noone;
		}
		
		self.__register = function(_ID) {
			var _suffix = 0;
			var _check_id = _ID.__ID;
			while (self.exists(_check_id)) {
				_suffix++;
				_check_id = _ID.__ID+string(_suffix);			
			}
			if (_suffix != 0)	{			
				self.__logMessage("Created widget ID renamed to '"+_check_id+"', because provided ID '"+_ID.__ID+"' already existed", UI_MESSAGE_LEVEL.WARNING);
				_ID.__ID = _check_id;
			}
			array_push(self.__widgets, _ID);
			variable_struct_set(self.__id_map, _ID.__ID, _ID);
			if (_ID.getType() == UI_TYPE.PANEL) array_push(self.__panels, _ID);
			if (_suffix == 0) self.__logMessage("Created widget '"+_ID.__ID+"'", UI_MESSAGE_LEVEL.INFO);				
		}
		
		self.__destroy_widget = function(_ID) {			
			var _i=0; 
			var _n = array_length(self.__widgets);
			var _found = false;
			while (_i<_n && !_found) {
				if (self.__widgets[_i] == _ID) {
					array_delete(self.__widgets, _i, 1);
					_found = true;						
				}
				else {
					_i++
				}					
			}
			if (_ID.getType() == UI_TYPE.PANEL) {
				var _i=0; 
				var _n = array_length(self.__panels);
				var _found = false;
				while (_i<_n && !_found) {
					if (self.__panels[_i] == _ID) {
						array_delete(self.__panels, _i, 1);
						_found = true;						
					}
					else {
						_i++
					}					
				}
			}
			if (variable_struct_exists(self.__id_map, _ID.__ID) && variable_struct_get(self.__id_map, _ID.__ID) == _ID)	variable_struct_remove(self.__id_map, _ID.__ID);
			if (_ID.getType() == UI_TYPE.CANVAS && _ID.__owns_surface && surface_exists(_ID.__surface_id))	surface_free(_ID.__surface_id);
			
			self.__logMessage("Destroyed widget '"+_ID.__ID+"'", UI_MESSAGE_LEVEL.INFO);
		}
	
		self.__keep_allowed_chars = function(_string, _allow_lowercase = true, _allow_uppercase = true, _allow_spaces = true, _allow_digits = true, _allow_symbols = true, _symbols_allowed = ",.") {
			var _n = string_length(_string);
			var _str = "";
			var _m = string_length(_symbols_allowed);
			for (var _i=1; _i<=_n; _i++) {
				var _o = string_ord_at(_string, _i);
				var _keep;
				if (_o == 32)				_keep = _allow_spaces;
				else if (_o >= 65 && _o <= 90)	_keep = _allow_uppercase;
				else if (_o >= 97 && _o <= 122)	_keep = _allow_lowercase;
				else if (_o >= 48 && _o <= 57)	_keep = _allow_digits;
				else {
					// Anything else is a symbol: allowed if symbols are on and either there is no whitelist or the character is in it
					_keep = _allow_symbols && (_m == 0 || string_pos(string_char_at(_string, _i), _symbols_allowed) > 0);
				}
				if (_keep)	_str += string_char_at(_string, _i);
			}
			return _str;
		}
	
	#endregion
	
	/// @method					getLogMessageLevel()
	/// @description			gets the message level for the library
	/// @return					{Enum}	The message level, according to UI_MESSAGE_LEVEL	
	self.getLogMessageLevel = function()		{ return self.__logMessageLevel; }
	
	/// @method					setLogMessageLevel
	/// @description			sets sthe message level for the library
	/// @param					{Enum}	_lvl	The message level, according to UI_MESSAGE_LEVEL
	/// @return					{UI}	self
	self.setLogMessageLevel = function(_lvl)	{ self.__logMessageLevel = _lvl; return self; }
	
	/// @method					getScale()
	/// @description			gets the global rendering scale multiplier of the UI (1 is the default)
	/// @return					{Real}	The global scale multiplier of the UI
	self.getScale = function()					{ return self.__scale; }
	
	/// @method					setScale(_scale)
	/// @description			sets the global rendering scale multiplier of the UI (1 is the default)
	/// @param					{Real}	_scale	The global scale multiplier of the UI
	/// @return					{UI}	self
	self.setScale = function(_scale)			{ self.__scale = _scale; self.__scale_tag = "[scale,"+string(_scale)+"]"; return self; }
	
	/// @method					resetScale()
	/// @description			resets the global rendering scale multiplier of the UI to 1x (1)
	/// @return					{Real}	The global scale multiplier of the UI
	self.resetScale = function()				{ self.__scale = 1; self.__scale_tag = "[scale,1]"; return self; }
	
	/// @method					getMouseDevice()
	/// @description			gets the currently used mouse device for handling mouse events. By default it's 0.
	/// @return					{Real}	The currently used mouse device
	self.getMouseDevice = function()			{ return self.__mouse_device; }
	
	/// @method					setMouseDevice(_device)
	/// @description			sets the mouse device for handling mouse events.
	/// @param					{Real}	_device	The number of the mouse device to use.
	/// @return					{UI}	self
	self.setMouseDevice = function(_device)		{ self.__mouse_device = _device; return self; }
	
	/// @method					getWidgets()
	/// @description			gets an array with all widgets currently registered
	/// @return					{Array<UIWidget>}	The array with the widgets
	self.getWidgets = function()				{ return self.__widgets; }
	
	/// @method					exists(_ID)
	/// @description			returns whether the specified Widget exists, identified by its *string ID* (not by its reference).
	/// @param					{String}	_ID		The Widget string ID
	/// @return					{Bool}	Whether the specified Widget exists
	self.exists = function(_ID)					{ return self.get(_ID) != noone; }
	
	/// @method					get(_ID)
	/// @description			gets a specific Widget by its *string ID* (not by its reference).
	/// @param					{String}	_ID		The Widget string ID
	/// @return					{Any}	The Widget's reference, or noone if not found
	self.get = function(_ID) {
		if (!is_string(_ID))	return noone;
		var _w = variable_struct_get(self.__id_map, _ID);
		return is_undefined(_w) ? noone : _w;
	}
	
	/// @method					getPanels()
	/// @description			gets an array with all Panel widgets currently registered
	/// @return					{Array<UIPanel>}	The array with the Panel widgets
	self.getPanels = function()					{ return self.__panels; }
	
	/// @method					getFocusedPanel()
	/// @description			gets the reference to the currently focused Panel widget, or -1 if no panels exist.
	/// @return					{UIPanel}	The reference to the currently focus Panel
	self.getFocusedPanel = function()			{ return array_length(self.__panels) > 0 ? self.__panels[array_length(self.__panels)-1] : -1; }
	
	/// @method					setFocusedPanel(_ID)
	/// @description			sets the specified Panel as focused
	/// @param					{String}	_ID		The Widget string ID	
	/// @return					{UI}	self
	self.setFocusedPanel = function(_ID) {
		var _pos = self.__getPanelIndex(_ID);
		if (_pos == noone) {
			self.__logMessage("setFocusedPanel: there is no Panel with ID '"+string(_ID)+"'", UI_MESSAGE_LEVEL.WARNING);
			return self;
		}
		var _ref = self.__panels[_pos];
		var _hovered = self.__getPanelByIndex(self.__currentlyHoveredPanel);
		array_delete(self.__panels, _pos, 1);
		array_push(self.__panels, _ref);
		if (_hovered != noone)	self.__currentlyHoveredPanel = array_get_index(self.__panels, _hovered);
		return self;
	}
	
	/// @method					isInteracting()
	/// @description			returns whether the user is interacting with the UI, to prevent clicks/actions "drilling-through" to the game
	/// @return					{Bool}	whether the user is interacting with the UI
	self.isInteracting = function() {				
		return self.__UI_interaction;
	}
			
	
	/// @method					getWidgetsByType(_type)
	/// @description			gets an array with all registered widgets of the specified type
	/// @param					{Enum}	_type	the widget type, according to the `UI_TYPE` enum
	/// @return					{Array<UIWidget>}	the array with the matching widgets (a new array)
	self.getWidgetsByType = function(_type) {
		var _a = [];
		for (var _i=0, _n=array_length(self.__widgets); _i<_n; _i++)	if (self.__widgets[_i].__type == _type)	array_push(_a, self.__widgets[_i]);
		return _a;
	}
	
	/// @method					getWidgetCount()
	/// @description			gets the number of registered widgets (including Panels)
	/// @return					{Real}	the number of widgets
	self.getWidgetCount = function()			{ return array_length(self.__widgets); }
	
	/// @method					getModalPanel()
	/// @description			gets the Panel that is currently modal, if any
	/// @return					{UIPanel}	the modal Panel, or `noone`
	self.getModalPanel = function() {
		for (var _i=array_length(self.__panels)-1; _i>=0; _i--)	if (self.__panels[_i].__modal)	return self.__panels[_i];
		return noone;
	}
	
	/// @method					isModalOpen()
	/// @description			returns whether a modal Panel exists
	/// @return					{Bool}	whether there is a modal Panel
	self.isModalOpen = function()				{ return self.getModalPanel() != noone; }
	
	/// @method					getHoveredPanel()
	/// @description			gets the Panel currently under the pointer
	/// @return					{UIPanel}	the hovered Panel, or `noone`
	self.getHoveredPanel						= function()	{ return self.__getPanelByIndex(self.__currentlyHoveredPanel); }
	
	/// @method					getHoveredWidget()
	/// @description			gets the (non-Panel) widget currently under the pointer
	/// @return					{UIWidget}	the hovered widget, or `noone`
	self.getHoveredWidget						= function()	{ return self.__currentlyHoveredWidget; }
	
	/// @method					getDraggedWidget()
	/// @description			gets the widget currently being dragged
	/// @return					{UIWidget}	the dragged widget, or `noone`
	self.getDraggedWidget						= function()	{ return self.__currentlyDraggedWidget; }
	
	/// @method					getCamera()
	/// @description			gets the camera used to map GUI coordinates to the screen
	/// @return					{Id.Camera}	the camera, or `undefined` if the application surface is used
	self.getCamera								= function()	{ return self.__camera_id; }
	
	/// @method					setCamera(_camera)
	/// @description			sets the camera used to map GUI coordinates to the screen (needed when using views with GUI scissors)
	/// @param					{Id.Camera}	_camera	the camera, or `undefined`
	/// @return					{UI}	self
	self.setCamera								= function(_camera)	{ self.__camera_id = _camera; return self; }
	
	/// @method					bringToFront(_ID)
	/// @description			brings a Panel to the front (same as `setFocusedPanel`)
	/// @param					{String}	_ID	the Panel string ID
	/// @return					{UI}	self
	self.bringToFront							= function(_ID)	{ return self.setFocusedPanel(_ID); }
	
	/// @method					sendToBack(_ID)
	/// @description			sends a Panel behind all the other Panels
	/// @param					{String}	_ID	the Panel string ID
	/// @return					{UI}	self
	self.sendToBack = function(_ID) {
		var _pos = self.__getPanelIndex(_ID);
		if (_pos != noone) {
			var _hovered = self.__getPanelByIndex(self.__currentlyHoveredPanel);
			var _ref = self.__panels[_pos];
			array_delete(self.__panels, _pos, 1);
			array_insert(self.__panels, 0, _ref);
			if (_hovered != noone)	self.__currentlyHoveredPanel = array_get_index(self.__panels, _hovered);
		}
		return self;
	}
	
	/// @method					destroyAll()
	/// @description			destroys every Panel (and therefore every widget). Same as `cleanup()` but safe to call at any time.
	/// @return					{UI}	self
	self.destroyAll = function() {
		for (var _i=array_length(self.__panels)-1; _i>=0; _i--)	self.__panels[_i].destroy();
		// Widgets that were created but never added to a panel
		for (var _i=array_length(self.__widgets)-1; _i>=0; _i--)	self.__widgets[_i].destroy();
		return self;
	}
	
	/// @method					render()
	/// @description			calls the UI library to render the Widgets. Run this in the Draw GUI Begin event of the manager object	
	self.render = function() {
		for (var _i=0, _n = array_length(self.__panels); _i<_n; _i++) {
			if (_i == _n-1 && self.__panels[_i].__modal && self.__panels[_i].__modal_color != -1) {
				draw_set_alpha(self.__panels[_i].__modal_alpha);
				draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), self.__panels[_i].__modal_color, self.__panels[_i].__modal_color,self.__panels[_i].__modal_color,self.__panels[_i].__modal_color, false);
				draw_set_alpha(1);
			}			
			self.__panels[_i].__render();
		}
	}
	
	/// @method					cleanup()
	/// @description			calls the UI library to cleanup the UI. Run this in the Clean Up of the manager object
	self.cleanup = function() {
		if (argument_count >= 1) throw("ERROR: trying to use UI method cleanup() to destroy an individual widget. Use widget.destroy() instead");
		self.destroyAll();
	}
	
#endregion

self.__logMessage("Welcome to "+UI_LIBRARY_NAME+" "+UI_LIBRARY_VERSION+", an user interface library by manta ray", UI_MESSAGE_LEVEL.NOTICE);


if (variable_global_exists("__gooey_manager_active")) {
	instance_destroy();
	exit;
}
global.__gooey_manager_active = self.id;