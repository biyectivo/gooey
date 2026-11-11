/// @description run all the tests once, report, and quit with an exit code usable by CI
if (self.done) exit;
self.done = true;

var _filter = environment_get_variable("GOOEY_TEST_FILTER");
var _results = gt_run_all(_filter);

show_debug_message(GT_LOG_PREFIX + "SUMMARY total=" + string(_results.total) + " passed=" + string(_results.passed) + " failed=" + string(_results.failed) + " errors=" + string(_results.errors) + " skipped=" + string(_results.skipped) + " assertions=" + string(global.__gt.assertions) + " duration_ms=" + string(round(_results.duration_ms)));
var _ok = (_results.failed == 0 && _results.errors == 0);
show_debug_message(GT_LOG_PREFIX + "RESULT: " + (_ok ? "PASS" : "FAIL"));

// JUnit XML (picked up by the command line runner and by CI)
var _file = file_text_open_write(working_directory + "gooey_test_results.xml");
if (_file != -1) {
	file_text_write_string(_file, _results.xml);
	file_text_close(_file);
}
show_debug_message(GT_LOG_PREFIX + "XML-BEGIN");
show_debug_message(_results.xml);
show_debug_message(GT_LOG_PREFIX + "XML-END");

game_end(_ok ? 0 : 1);
