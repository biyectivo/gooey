function __auto_create_ui_object() {
	if (!variable_global_exists("__gooey_manager_active")) {
		var _layer = layer_create(16000, "lyr_gooey");
		instance_create_layer(-1, -1, _layer, UI);
	}
}

/// @function				ui_exists(_ID)
/// @description			returns whether the specified Widget exists, identified by its *string ID* (not by its reference).
/// @param					{String}	_ID		The Widget string ID
/// @return					{Bool}	Whether the specified Widget exists
function ui_exists(_id) {
	__auto_create_ui_object();
	return UI.exists(_id);
}

/// @function				ui_get(_ID)
/// @description			gets a specific Widget by its *string ID* (not by its reference).
/// @param					{String}	_ID		The Widget string ID
/// @return					{Any}	The Widget's reference, or noone if not found
function ui_get(_id) {
	__auto_create_ui_object();
	return UI.get(_id);
}

/// @function				ui_is_interacting()
/// @description			returns whether the user is interacting with the UI, to prevent clicks/actions "drilling-through" to the game
/// @return					{Bool}	whether the user is interacting with the UI
	
function ui_is_interacting() {
	__auto_create_ui_object();
	return UI.isInteracting();
}