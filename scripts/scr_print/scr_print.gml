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