// Comment out this line if your game is not 2D
surface_depth_disable(true);

enum UIMSGLEVEL {
	INFO,
	WARNING,
	ERROR,
	NOTICE
}
#region Private variables
	self.__scale = 1;
	self.__mouse_device = 0;
	self.__widgets = [];
	self.__panels = [];
	self.__currentlyHoveredPanel = noone;
	self.__currentlyDraggedWidget = noone;
	self.__drag_start_x = -1;
	self.__drag_start_y = -1;
	self.__drag_mouse_delta_x = -1;
	self.__drag_mouse_delta_y = -1;
	self.__logMessageLevel = UIMSGLEVEL.INFO;
#endregion
#region Setters/Getters and Methods
	self.getLogMessageLevel = function()		{ return self.__logMessageLevel; }
	self.setLogMessageLevel = function(_lvl)	{ self.__logMessageLevel = _lvl; }
	self.logMessage = function(_msg, _lvl)	{ 
		var _lvls = ["INFO", "WARNING", "ERROR", "NOTICE"];
		if (_lvl >= self.__logMessageLevel) {
			show_debug_message("["+UI_LIBRARY_NAME+"] <"+ _lvls[_lvl]+"> "+_msg);
		}
	}
	self.getScale = function()					{ return self.__scale; }
	self.setScale = function(_scale)			{ self.__scale = _scale; }
	self.resetScale = function()				{ self.__scale = 1; }
	self.getMouseDevice = function()			{ return self.__mouse_device; }
	self.setMouseDevice = function(_device)		{ self.__mouse_device = _device; }
	self.getWidgets = function()				{ return self.__widgets; }
	self.getByIndex = function(_idx)			{ return _idx >= 0 && _idx < array_length(self.__widgets) ? self.__widgets[_idx] : noone; }			
	self.exists = function(_ID)					{ return self.get(_ID) != noone; }
	self.get = function(_ID) {
		var _i = 0;
		var _n = array_length(self.__widgets);
		var _found = false;
		while (_i<_n && !_found) {
			if (self.__widgets[_i].getID() == _ID) {
				_found = true;
			}
			else {
				_i++;
			}
		}
		return _found ? self.__widgets[_i] : noone;
	}			
	self.getPanels = function()					{ return self.__panels; }
	self.getPanelByIndex = function(_idx)		{ return _idx >= 0 && _idx < array_length(self.__panels) ? self.__panels[_idx] : noone; }
	self.getPanelIndex = function(_ID) {
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
	self.getFocusedPanel = function()			{ return self.__panels[array_length(self.__panels)-1]; }
	self.setPanelFocus = function(_ref) {				
		var _pos = self.getPanelIndex(_ref.getID());
		array_delete(self.__panels, _pos, 1);
		array_push(self.__panels, _ref);		
	}
	self.register = function(_ID) {
		var _suffix = 0;
		var _check_id = _ID.__ID;
		while (self.exists(_check_id)) {
			_suffix++;
			_check_id = _ID.__ID+string(_suffix);			
		}
		if (_suffix != 0)	{			
			self.logMessage("Created widget ID renamed to '"+_check_id+"', because provided ID '"+_ID.__ID+"' already existed", UIMSGLEVEL.WARNING);
			_ID.__ID = _check_id;
		}
		array_push(self.__widgets, _ID);
		if (_ID.getType() == UI_TYPE.PANEL) array_push(self.__panels, _ID);
	}
	self.destroy = function(_ID) {
		self.logMessage("Destroying widget with ID '"+_ID.__ID+"'", UIMSGLEVEL.INFO);
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
	}
	self.processEvents = function() {
		window_set_cursor(cr_default);
		
		// Process events on all widgets
		var _n = array_length(self.__widgets);
		for (var _i = _n-1; _i>=0; _i--) {
			self.__widgets[_i].processEvents();
		}
		// Determine topmost mouseovered panel
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
		self.__currentlyHoveredPanel = _i >= 0 ? _i : noone;
		if (self.__currentlyHoveredPanel != noone) {			
			// Determine topmost widget
			var _panel = self.getPanelByIndex(self.__currentlyHoveredPanel);			
			var _children = _panel.getAllChildren();
			
			// Process events on all children widgets
			var _n = array_length(_children);
			for (var _i = _n-1; _i>=0; _i--) {
				_children[_i].processEvents();
			}
			
			// Determine children widget to execute callbacks depending on the processed events
			_i=_n-1;
			var _mouse_over = false;
			while (_i>=0 && !_mouse_over) {
				if (_children[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
					_mouse_over = true;
				}
				else {
					_i--;
				}
			}
			if (_mouse_over) {
				_children[_i].__builtInBehavior();
			}
			else {
				_panel.__builtInBehavior();
			}
		}
		
		// Drag
		if (obj_UI.__currentlyDraggedWidget != noone && obj_UI.__currentlyDraggedWidget.__draggable) {			
			obj_UI.__currentlyDraggedWidget.__drag();			
		}
	}
	self.render = function() {
		for (var _i=0, _n = array_length(self.__panels); _i<_n; _i++) {
			self.__panels[_i].render();
		}
	}
	self.cleanUp = function() {
		for (var _i=array_length(self.__panels)-1; _i>=0; _i--) {			
			self.__panels[_i].cleanUp();			
		}
	}
#endregion

self.logMessage("Welcome to "+UI_LIBRARY_NAME+", an user interface library by manta ray", UIMSGLEVEL.NOTICE);