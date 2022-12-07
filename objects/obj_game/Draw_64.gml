var _align = draw_get_halign();
draw_set_halign(fa_right);
draw_text(display_get_gui_width()-20, 10, "FPS " + string(fps_real));
if (UI.getFocusedPanel() != -1)				draw_text(display_get_gui_width()-20, 30, "Focused panel: " + string(UI.getFocusedPanel().getID()));
if (UI.__currentlyHoveredPanel >= 0)		draw_text(display_get_gui_width()-20, 60, "Mouseovered panel: " + string(UI.__getPanelByIndex(UI.__currentlyHoveredPanel).getID()));
if (UI.__currentlyHoveredPanel >= 0 && UI.__currentlyHoveredWidget != noone)		draw_text(display_get_gui_width()-20, 90, "Mouseovered widget: " + UI.__currentlyHoveredWidget.getID());
if (UI.__currentlyDraggedWidget != noone)		draw_text(display_get_gui_width()-20, 120, "Dragged widget: " + UI.__currentlyDraggedWidget.getID());
//draw_text(display_get_gui_width()-20, 120, "Dragged widget: " + UI.__currentlyDraggedWidget);
draw_set_halign(_align);