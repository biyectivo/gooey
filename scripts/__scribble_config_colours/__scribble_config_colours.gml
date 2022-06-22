/// Creates a collection of colour names that map to 24-bit BGR colours
/// Use scribble_rgb_to_bgr() to convert from industry standard RGB colour codes to GM's native BGR format
///
/// N.B. That this script is executed on boot. You never need to run this script yourself!

global.__scribble_colours = {
    //Duplicate GM's native colour constants
    col_aqua:    c_aqua,
    col_black:   c_black,
    col_blue:    c_blue,
    col_dkgray:  c_dkgray,
    col_dkgrey:  c_dkgrey,
    col_fuchsia: c_fuchsia,
    col_gray:    c_gray,
    col_green:   c_green,
    col_gray:    c_gray,
    col_lime:    c_lime,
    col_ltgray:  c_ltgray,
    col_ltgrey:  c_ltgrey,
    col_maroon:  c_maroon,
    col_navy:    c_navy,
    col_olive:   c_olive,
    col_orange:  c_orange,
    col_purple:  c_purple,
    col_red:     c_red,
    col_silver:  c_silver,
    col_teal:    c_teal,
    col_white:   c_white,
    col_yellow:  c_yellow,
}
