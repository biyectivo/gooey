# Testing gooey

gooey ships with an automated test suite that runs **inside GameMaker** (so it exercises the real runtime, Scribble, surfaces and
drawing) and can also be launched **headlessly from the command line**. It is meant to run on every change.

| Layer | What | Where |
|---|---|---|
| Unit/behavior tests | ~200 tests / ~600 assertions: manager & registry, positioning, base widget, every widget, events, drag/resize, tabs, modal, bindings, scale, utilities | `scripts/scr_Gooey_Tests_*` |
| Framework | Tiny xUnit-style framework (`gt_suite`, `gt_assert_*`), simulated mouse/keyboard, JUnit XML output | `scripts/scr_Gooey_Test_Framework` |
| Test runner | Object + room that run the suites and quit with an exit code | `obj_gooey_tests`, `rm_gooey_tests` |
| Static checks | JSDoc vs implementation (names, parameters, constructors, getters) | `tools/check_docs.py` |
| Command line | Builds a throw-away copy of the project with Igor, runs the room, parses the result | `tools/run_tests.ps1` |

## Running the tests

### From the command line (recommended, ~30 s)

```powershell
./tools/run_tests.ps1                    # everything
./tools/run_tests.ps1 -Filter "Panel ::" # only tests whose "Suite :: name" contains the text
./tools/run_tests.ps1 -Keep              # keep the temporary project copy (to debug build errors)
```

Exit code `0` = all passed, `1` = failures, errors, build errors or timeout. Reports are written to `tests/results/`
(`junit.xml`, `igor.log`). Requirements: Windows, GameMaker installed (runtime + Igor), a desktop session (the tests open a window),
and optionally Python 3 for the documentation check. The script auto-detects the newest runtime / user folder / prefabs; override with
`-RuntimePath`, `-UserFolder`, `-PrefabsFolder`.

How it works: the project is copied to a temp folder (the working tree is never touched), `rm_gooey_tests` is moved to the front of the
room order, the prefab the project links to is copied to `<copy>/prefabs` (Igor looks it up there), and `Igor windows Run` builds & runs with
the VM runtime. The game prints `[GOOEY-TEST] PASS/FAIL/ERROR ...` lines and a final `RESULT: PASS|FAIL`, then calls `game_end()` with the exit code.
An unhandled-exception handler turns runtime crashes into a failing result instead of a blocking error dialog.

### From the GameMaker IDE

Open `rm_gooey_tests`, set it as the first room (or just run with it selected as the start room) and press Run. The results appear in the Output
window; the window closes when finished.

## Writing tests

```gml
function gt_register_my_widget() {
    var _s = gt_suite("MyWidget");
    _s.test("does something", function() {
        var _panel = new UIPanel("P", 100, 100, 400, 300, grey_panel);
        var _b = _panel.add(new UIButton("B", 20, 60, 120, 40, "ok", blue_button00));
        gt_click(_b);                       // simulated hover + press + release (3 frames of event processing)
        gt_assert_true(...);
    });
}
```

1. Put the suite in a script (folder *gooey / Tests / Suites*) and call its `gt_register_*()` from `gooey_register_all_tests()` (`scr_Gooey_Tests_Layout`).
2. Every test starts from a clean UI (`gt_reset_ui()` destroys all widgets, resets scale/mouse device and installs a fresh simulated mouse).
3. Helpers: `gt_mouse()` (`moveTo/press/release/scrollUp/pressKey`), `gt_frame(n)` (process events), `gt_render()` (draw), `gt_click`, `gt_hover`, `gt_center`.
4. Assertions: `gt_assert_true/false/equal/not_equal/near/undefined/defined/throws/no_throw`, `gt_fail`. Regular GameMaker runtime errors inside a test are reported as `ERROR`.
5. Use `_s.skip(name, fn)` to park a test that documents a known limitation.

### The input seam

All pointer/keyboard reads in gooey go through `__gooey_mouse_x/y`, `__gooey_mouse_down/pressed/released`, `__gooey_wheel_up/down`,
`__gooey_key_down/pressed` (`scr_UI_Input`). `ui_set_input_provider(struct)` replaces any of them, which is how the tests drive the UI deterministically.
It is also a public feature: use it for gamepad-driven cursors, replays, remapping or touch emulation.

## Git hook

```powershell
git config core.hooksPath .githooks
```

enables `.githooks/pre-commit`, which runs the documentation check on every commit and (if `GOOEY_TESTS_ON_COMMIT=1`) the full suite.
The full suite takes ~30 s, so by default it is left to CI/pre-push.

## CI/CD plan

GameMaker needs a Windows machine with a desktop session and a licence/user folder, which rules out GitHub-hosted runners for the build step.
The repository includes `.github/workflows/tests.yml` for a **self-hosted Windows runner**:

1. **Now (implemented):** `docs-check` job on GitHub-hosted Ubuntu (Python only; runs on every push/PR) + `gooey-tests` job on a self-hosted runner labelled `gamemaker`
   (runs `tools/run_tests.ps1`, uploads `junit.xml`/`igor.log`, publishes a test summary).
2. **Next:** cache the Igor `--cache` folder between runs; add a matrix over the runtime versions the library supports (stable + beta) by pinning `-RuntimePath`;
   fail PRs on any warning in the build log.
3. **Later:** (a) package job that builds the `.yymps` on tags and attaches it to the GitHub release (replaces the committed `builds/` folder);
   (b) screenshot/regression tests: render known layouts to a surface, `surface_save` and compare with golden PNGs (the input seam and `gt_render()` already make this possible);
   (c) a performance budget test (create N widgets, time `__processEvents`/`render`, fail on regression);
   (d) regenerate the documentation site (GMLDocMaker) from the JSDoc in CI and fail if the checked-in API reference is stale;
   (e) YYC build smoke test (compile only) because YYC is stricter than VM.
