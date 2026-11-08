/// @description gooey test runner: registers the suites; the tests themselves run on the first Draw GUI event
/// (some widgets can only be exercised inside a draw event)
self.done = false;
gooey_register_all_tests();

// Never block on the runtime's error dialog: report and quit with a failing exit code
exception_unhandled_handler(function(_e) {
	show_debug_message(GT_LOG_PREFIX + "FATAL " + (is_struct(_e) && variable_struct_exists(_e, "longMessage") ? _e.longMessage : string(_e)));
	show_debug_message(GT_LOG_PREFIX + "RESULT: FAIL");
	game_end(2);
	return 0;
});
