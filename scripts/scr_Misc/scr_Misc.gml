function __game_restart() {
	with(all) {
		if (!self.persistent) instance_destroy();	
	}

	audio_stop_all();
	draw_texture_flush();
	
	UI.cleanup();
	
	room_goto(room_first);
}