if (!surface_exists(self.surface_id))		self.surface_id = surface_create(100, 100);
surface_set_target(self.surface_id);
draw_clear_alpha(c_black, 0);
draw_set_alpha(1);
var _q = 10*sin(current_time/1000);
draw_triangle_color(10+_q, 10+_q, 90+_q, 90+_q, 90+_q, 10+_q, c_red, c_blue, c_lime, false);
draw_set_alpha(1);
surface_reset_target();