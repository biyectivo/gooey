var _align = draw_get_halign();
draw_set_halign(fa_right);
draw_text(display_get_gui_width()-20, 10, "FPS " + string(fps_real));
if (UI.getFocusedPanel() != -1)		draw_text(display_get_gui_width()-20, 20, "Active panel: " + string(UI.getFocusedPanel().getID()));
draw_set_halign(_align);