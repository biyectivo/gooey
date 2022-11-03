var _align = draw_get_halign();
draw_set_halign(fa_right);
draw_text(display_get_gui_width()-10, 10, "Clip " + string(UI.exists("Panel3") ? UI.get("Panel3").getClipsContent() : ""));
draw_set_halign(_align);