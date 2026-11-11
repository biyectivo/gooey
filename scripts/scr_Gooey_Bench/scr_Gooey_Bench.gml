/// @feather ignore all
/************************************************************************************
	gooey micro-benchmarks. They only run when the test filter contains "Bench", e.g.
		./tools/run_tests.ps1 -Filter "Bench ::" -Keep
	and print `[GOOEY-BENCH] name: X us/frame` lines to the Igor log (tests/results/igor.log).
	Numbers are VM-runtime numbers: relative changes are meaningful, absolute ones are ~3-10x slower than YYC.
*************************************************************************************/

function gt_bench_enabled() {
	var _f = environment_get_variable("GOOEY_TEST_FILTER");
	return (_f != "" && string_pos("Bench", _f) > 0);
}

/// builds `_panels` panels with `_per_panel` mixed widgets each; returns the array of panels
function gt_bench_build(_panels, _per_panel) {
	var _list = [];
	for (var _p=0; _p<_panels; _p++) {
		var _panel = new UIPanel("BP"+string(_p), 10 + _p*12, 10 + _p*12, 900, 700, grey_panel);
		for (var _i=0; _i<_per_panel; _i++) {
			var _x = 10 + (_i mod 10) * 85, _y = 40 + (_i div 10) * 28;
			switch (_i mod 5) {
				case 0: _panel.add(new UIButton("b"+string(_p)+"_"+string(_i), _x, _y, 80, 24, "btn", blue_button00)); break;
				case 1: _panel.add(new UIText("t"+string(_p)+"_"+string(_i), _x, _y, "text "+string(_i))); break;
				case 2: _panel.add(new UICheckbox("c"+string(_p)+"_"+string(_i), _x, _y, "chk", yellow_checkmark, yellow_cross, false)); break;
				case 3: _panel.add(new UISlider("s"+string(_p)+"_"+string(_i), _x, _y, 80, noone, yellow_circle, 50, 0, 100)); break;
				case 4: _panel.add(new UIProgressBar("p"+string(_p)+"_"+string(_i), _x, _y, yellow_circle, yellow_circle, 50, 0, 100)); break;
			}
		}
		array_push(_list, _panel);
	}
	return _list;
}

function gt_bench_time(_name, _fn, _iterations) {
	_fn(); _fn();	// warm-up (fills Scribble caches)
	var _t0 = get_timer();
	// 7 batches, report the fastest batch (robust against background noise on the machine)
	var _us = 1000000000;
	var _per = max(1, _iterations div 4);
	repeat (7) {
		_t0 = get_timer();
		repeat (_per) _fn();
		_us = min(_us, (get_timer() - _t0) / _per);
	}
	show_debug_message("[GOOEY-BENCH] " + _name + ": " + string_format(_us, 1, 1) + " us/frame");
}

function gt_bench_type(_kind, _n) {
	var _panel = new UIPanel("BT", 10, 10, 1000, 900, grey_panel);
	for (var _i=0; _i<_n; _i++) {
		var _x = 10 + (_i mod 10) * 90, _y = 40 + (_i div 10) * 30, _id = "w"+string(_i);
		switch (_kind) {
			case 0: _panel.add(new UIButton(_id, _x, _y, 80, 24, "btn", blue_button00)); break;
			case 1: _panel.add(new UIText(_id, _x, _y, "text "+string(_i))); break;
			case 2: _panel.add(new UICheckbox(_id, _x, _y, "chk", yellow_checkmark, yellow_cross, false)); break;
			case 3: _panel.add(new UISlider(_id, _x, _y, 80, noone, yellow_circle, 50, 0, 100)); break;
			case 4: _panel.add(new UIProgressBar(_id, _x, _y, yellow_circle, yellow_circle, 50, 0, 100)); break;
		}
	}
	return _panel;
}

function gt_bench_gc_objects() {
	gc_collect();
	var _st = gc_get_stats();
	var _sum = 0;
	for (var _i=0; _i<array_length(_st.num_objects_in_generation); _i++)	_sum += _st.num_objects_in_generation[_i];
	return _sum;
}


function gt_register_bench() {
	var _s = gt_suite("Bench");

	_s.test("memory per widget (struct variables and GC object counts)", function() {
		if (!gt_bench_enabled()) return;
		var _names = ["button", "text", "checkbox", "slider", "progressbar"];
		for (var _k=0; _k<5; _k++) {
			gt_reset_ui();
			var _before = gt_bench_gc_objects();
			var _panel = gt_bench_type(_k, 100);
			var _w = _panel.getChildren()[0];
			var _after = gt_bench_gc_objects();
			show_debug_message("[GOOEY-BENCH] M " + _names[_k] + ": struct vars=" + string(struct_names_count(_w)) + " gc objects/widget=" + string((_after-_before)/101));
		}
	});

	_s.test("per type, 200 widgets of one kind", function() {
		if (!gt_bench_enabled()) return;
		var _names = ["button", "text", "checkbox", "slider", "progressbar"];
		for (var _k=0; _k<5; _k++) {
			gt_reset_ui();
			gt_bench_type(_k, 200);
			gt_render();
			gt_mouse().moveTo(1500, 1000);
			gt_bench_time("E render " + _names[_k] + " x200 (mouse outside)", function() { gt_render(); }, 100);
			gt_mouse().moveTo(500, 300);
			gt_bench_time("E events " + _names[_k] + " x200 (mouse in panel)", function() { gt_frame(); }, 100);
		}
	});

	_s.test("hovered, 1 panel x 200 widgets", function() {
		if (!gt_bench_enabled()) return;
		var _ps = gt_bench_build(1, 200);
		gt_render();
		gt_mouse().moveTo(500, 300);
		gt_bench_time("A1 events (mouse over panel, 200 widgets)", function() { gt_frame(); }, 200);
		gt_bench_time("A2 render  (200 widgets)", function() { gt_render(); }, 200);
	});

	_s.test("idle mouse outside, 10 panels x 40 widgets", function() {
		if (!gt_bench_enabled()) return;
		var _ps = gt_bench_build(10, 40);
		gt_render();
		gt_mouse().moveTo(1900, 1000);
		gt_bench_time("B1 events (mouse outside all panels, 400 widgets)", function() { gt_frame(); }, 200);
		gt_bench_time("B2 render  (400 widgets)", function() { gt_render(); }, 100);
	});

	_s.test("hovered, 5 panels x 100 widgets, text heavy", function() {
		if (!gt_bench_enabled()) return;
		var _ps = gt_bench_build(5, 100);
		gt_render();
		var _top = _ps[4];
		gt_mouse().moveTo(_top.getDimensions().x + 200, _top.getDimensions().y + 200);
		gt_bench_time("C1 events (mouse over top panel, 500 widgets total)", function() { gt_frame(); }, 200);
		gt_bench_time("C2 render  (500 widgets)", function() { gt_render(); }, 100);
	});

	_s.test("scrolled list: 400 buttons + 400 texts in a clipping group, ~6% visible", function() {
		if (!gt_bench_enabled()) return;
		var _ui = global.__gooey_manager_active;
		var _p = new UIPanel("BL", 10, 10, 1000, 700, grey_panel);
		var _g = _p.add(new UIGroup("BLG", 10, 40, 900, 600, noone));
		_g.setClipsContent(true);
		for (var _i=0; _i<400; _i++) {
			_g.add(new UIButton("lb"+string(_i), 10 + (_i mod 8) * 110, 10 + (_i div 8) * 40, 100, 30, "item " + string(_i), blue_button00));
			_g.add(new UIText("lt"+string(_i), 10 + (_i mod 8) * 110, 14 + (_i div 8) * 40 + 900, "caption " + string(_i)));
		}
		_g.scroll(UI_ORIENTATION.VERTICAL, -1, 1000);	// most items are now above the visible area
		gt_render();
		gt_mouse().moveTo(500, 300);
		_ui.setCulling(false);
		gt_bench_time("F1 render scrolled list, culling OFF", function() { gt_render(); }, 100);
		gt_bench_time("F2 events scrolled list", function() { gt_frame(); }, 100);
		_ui.setCulling(true);
		gt_bench_time("F3 render scrolled list, culling ON", function() { gt_render(); }, 100);
	});

	_s.test("everything visible: culling overhead", function() {
		if (!gt_bench_enabled()) return;
		var _ui = global.__gooey_manager_active;
		var _ps = gt_bench_build(5, 100);
		gt_render();
		_ui.setCulling(false);
		gt_bench_time("G1 render 500 visible widgets, culling OFF", function() { gt_render(); }, 100);
		_ui.setCulling(true);
		gt_bench_time("G2 render 500 visible widgets, culling ON", function() { gt_render(); }, 100);
		gt_reset_ui();
		for (var _k=0; _k<2; _k++) {
			var _p = gt_bench_type(_k, 200);
			gt_render();
			_ui.setCulling(false);
			gt_bench_time("G3 render " + (_k == 0 ? "button" : "text") + " x200, culling OFF", function() { gt_render(); }, 100);
			_ui.setCulling(true);
			gt_bench_time("G4 render " + (_k == 0 ? "button" : "text") + " x200, culling ON", function() { gt_render(); }, 100);
			gt_reset_ui();
		}
	});

	_s.test("construction cost", function() {
		if (!gt_bench_enabled()) return;
		var _t0 = get_timer();
		gt_bench_build(1, 500);
		show_debug_message("[GOOEY-BENCH] D1 create 500 widgets: " + string_format((get_timer()-_t0)/1000, 1, 1) + " ms");
		var _t1 = get_timer();
		gt_reset_ui();
		show_debug_message("[GOOEY-BENCH] D2 destroy 500 widgets: " + string_format((get_timer()-_t1)/1000, 1, 1) + " ms");
	});
}
