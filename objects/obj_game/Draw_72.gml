if (!surface_exists(mysurface))		mysurface = surface_create(100, 100);
surface_set_target(mysurface);
draw_clear_alpha(c_black, 0);
draw_set_alpha(0.6);
draw_triangle_color(10, 10, 90, 90, 90, 10, c_red, c_blue, c_lime, false);
draw_set_alpha(1);
surface_reset_target();