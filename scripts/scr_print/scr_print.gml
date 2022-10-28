///@function			print
///@description			allows printing a string with embedded variable values
///@param				_string	the string using $w.d$ specifiers for each value
///@param				_args	an array with the corresponding values to embed
function print(_string, _args=[]) {	
	var _str = string_replace(_string, "$$", "¬");
	var _occurrences = string_split(_str, "$");
	var _n = array_length(_occurrences);
	
	var _new_args = [];
	if (!is_array(_args))	_new_args = [string(_args)];
	else _new_args = _args;
	
	if (_n % 2 != 1)	throw("Unbalanced variable identifier start/end characters ($)");
	else if ((_n-1)/2 > array_length(_new_args))	throw("Argument array be equal or larger than the number of variable identifiers");
	else {
		var _newstr = "";
		for (var _i=0; _i<_n; _i++) {
			if (_i % 2 == 0)	_newstr += _occurrences[_i];
			else {
				try {					
					var _r = real(_occurrences[_i]);					
					_newstr += string_format(_new_args[(_i-1)/2], floor(_r), 10 * (_r - floor(_r)));
				}
				catch (_ex) {
					_newstr += string(_new_args[(_i-1)/2]);
				}
			}
		}		
		show_debug_message(string_replace(_newstr, "¬", "$"));
	}
}


/// @function				string_split(_string, _delimiter)
/// @description			splits a string into an array
/// @param	{String}		_string		the string to split
/// @param	{String}		_delimiter	the delimiter to use in order to split the string
/// @return	{Array<String>}	the array containing the split string
function string_split(_string, _delimiter) {
	var _i=1;
	var _result = [];
	var _remaining = _string;
	var _n = string_length(_remaining);
	while (_n > 0) {
		var _pos = string_pos(_delimiter, _remaining);
		var _i = (_pos > 0) ? _pos-1 : string_length(_remaining);
		array_push(_result, string_copy(_remaining, 1, _i));
		_remaining = _pos == 0 ? "" : string_copy(_remaining, _pos+1, string_length(_remaining)-_pos);	
		_n = string_length(_remaining);
	}
	if (string_char_at(_string, string_length(_string)) == _delimiter)	array_push(_result, "");
	return _result;
}


/*
#macro print show_debug_message
/// @function		f(_text)
/// @description	formats text as in Python, supporting curly brace expressions
/// @param			{String}	_text	the string literal.
///								place struct or instance variable names between curly braces to integrate them
///								example: f("player: {self.x},{obj_Player.y} has health {health}")
///								note: always try to use fully qualified variable names
/// @return			{String}	the formatted string

function f(_text) {
	var _r_open = "°";
	var _r_close = "¬";
	if (string_pos("{", _text) == 0 || string_pos("}", _text) == 0)          return _text;	  
	
	var _split = string_split(string_replace_all(string_replace_all(_text, "\\}", _r_close), "\\{", _r_open), "{");	
	
	var _str = "";
	for (var _i=0, _n=array_length(_split); _i<_n; _i++) {
		// Now each item has either a literal value (length 1) or a two length array (length 2) where the first item will be the variable to resolve and the second is a literal value
		_split[_i] = string_split(_split[_i], "}");
		if (array_length(_split[_i]) == 2) {
			// Review the first item to check if we have a literal value (length 1) or a two length array (length 2) where the first item is the struct/instance name and the second is the variable name.
			_split[_i][0] = string_split(_split[_i][0], ".");
			if (array_length(_split[_i][0]) == 2) {
				var _id = asset_get_index(_split[_i][0][0]);
				var _var = _split[_i][0][1];
			}
			else {
				var _id = self;
				var _var = _split[_i][0][0];
			}
			
			var _value = infinity;
			if (is_struct(_id) && variable_struct_exists(_id, _var)) {
				var _value = string(variable_struct_get(_id, _var));				
			}
			else if (variable_instance_exists(_id, _var)) {
				var _value = string(variable_instance_get(_id, _var));				
			}
			
			if (_value != infinity) {
				_split[_i][0] = _value;					 
			}
			
			_str += string(_split[_i][0])+string(_split[_i][1]);
		}
		else if (array_length(_split[_i]) == 1) {
			_str += string(_split[_i][0]);
		}
	}
	return string_replace_all(string_replace_all(_str, _r_open, "{"), _r_close, "}");
}
*/