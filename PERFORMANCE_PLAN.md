# gooey performance & memory plan (proposal - nothing in here is implemented yet)

Branch: `analysis/deep-review`. Measured with the new micro-benchmark suite (`scripts/scr_Gooey_Bench`, run with
`./tools/run_tests.ps1 -Filter "Bench ::" -Keep`, results in `tests/results/igor.log`, lines `[GOOEY-BENCH]`).

> **Reading the numbers.** All measurements are **VM runtime**, CPU time only (no GPU), headless window, Scribble warm.
> YYC is typically 3-10x faster in absolute terms, so treat FPS as "relative headroom": what matters is the **ms saved per frame**
> and the **percentage**. The gains below are *estimates* derived from reading the code and the per-widget-type measurements;
> each item says how it will be verified, and I will report the measured number after implementing it (and drop items that do not pay off).

## 1. Baseline

Frame cost = events (`UI.__processEvents`, Step) + render (`UI.render`, Draw GUI).

| Scenario | Events | Render | Total | = FPS (VM) |
|---|---|---|---|---|
| A: 1 panel, 200 mixed widgets, mouse over panel | 4.64 ms | 6.98 ms | 11.6 ms | ~86 |
| B: 10 panels x 40 widgets (400), mouse **outside** every panel (idle) | 1.22 ms | 14.96 ms | 16.2 ms | ~62 |
| C: 5 panels x 100 widgets (500), mouse over top panel | 2.45 ms | 17.77 ms | 20.2 ms | ~49 |

Per widget type, 200 widgets of one kind in one panel:

| Widget | Render (us/widget) | Events (us/widget, mouse in panel) |
|---|---|---|
| Button | 26 | 16 |
| Text | 27 | 25 |
| Checkbox | 34 | 16 |
| Slider | **66** | 16 |
| ProgressBar | 10 | 14 |

Construction / destruction of 500 widgets: **38 ms / 63 ms** (a visible hitch when opening a big dialog).

Memory (GML does not expose bytes, so measured as struct variables and GC-tracked objects per widget):

| Widget | Struct variables | GC objects per widget |
|---|---|---|
| Button | 215 | 183 |
| Text | 208 | 172 |
| Checkbox | 222 | 187 |
| Slider | 236 | 195 |
| ProgressBar | 222 | 183 |

Almost all of those are **per-instance method closures**: every constructor does `self.getX = function() {...}` about 150-200 times,
so each widget carries its own copy of every method, plus ~8 more in its `__UIDimensions`. 500 widgets = ~90,000 GC objects.
My estimate is 15-25 KB per widget (about 10-12 MB for 500 widgets), and the garbage collector has to traverse all of it.

## 2. Where the time goes (findings)

| # | Finding | Evidence |
|---|---|---|
| F1 | Every widget `__processEvents` makes ~13 input-seam calls per frame (mouse x/y, 3x pressed, 3x down, 3x released, 2x wheel), each re-checking the provider and `getMouseDevice()` through `global.__gooey_manager_active` | `scr_UI_Widget.gml` 1207-1226 |
| F2 | The event pass runs for **every** descendant of the hovered panel even when the pointer is far from it (no early-out), and `__processMouseover` walks the whole parent chain with function calls each time | `Create_0.gml` 139-157, `__processMouseover` |
| F3 | `UIText.__processMouseover` builds a Scribble element + wrap + `get_bbox` every frame for every text widget (text events cost 25 us vs 16 us) | `scr_UI_Widget.gml` 1160-1164 |
| F4 | `getDescendants()` allocates and fills a fresh array recursively every call. The manager calls it every frame for the hovered panel and, when the mouse is outside all panels, for **every** panel (idle scenario B still costs 1.2 ms). `__gooey_array_clone(self.__widgets)` also runs every frame | `Create_0.gml` 125-137, 188, 206 |
| F5 | Draw path builds strings every frame: `"[scale,"+string(scale)+"]" + format + string(text)` then a Scribble cache lookup (hash of the string) per text draw | Button/Text/Checkbox/DropDown `__draw` |
| F6 | Slider draw is 2.5x a button: creates up to 3 Scribble elements per frame, creates a `_handle` struct, calls `setDimensions()` every frame (which recomputes coordinates) | `scr_UI_Slider.gml` ~380-440 |
| F7 | Draw path repeats `global.__gooey_manager_active.getScale()` (global lookup + method call) several times per widget; `__pre_render_callback()` / `__post_render_callback()` are called even when empty; the binding block runs `string()` and writes 4 fields every frame for bound widgets; `gpu_get_scissor()` allocates a struct per clipping widget | `__render` |
| F8 | No culling: widgets scrolled out of a clipping parent or outside the screen are still fully drawn (scissor only discards fragments) | `__render` |
| F9 | ~200 closures per widget (memory + GC traversal + 38/63 ms create/destroy for 500 widgets) | section 1 |
| F10 | When `UI_USE_SCISSORS = false`, every clipping widget allocates a **GUI-sized surface** (about 8 MB at 1920x1080) and clears it each frame. Default is scissors, so this only affects users who turn them off | `__render` |

## 3. Proposed changes

Estimates: ms saved in scenario C (500 widgets) unless noted, and the FPS that gives on its own. They are not additive in FPS
(FPS is 1/frame time), so the combined projection is in section 4.

### Phase 1 - low risk, no API changes (target: 2-3 days of work, ~1 day to verify)

| ID | Change | Est. saving | Est. FPS gain | Risk |
|---|---|---|---|---|
| P1 | **Sample input once per frame**: the manager snapshots mouse x/y, button states and wheel into a struct at the start of `__processEvents`; widgets read the snapshot instead of 13 seam calls. The seam (`ui_set_input_provider`) stays the single source, it is just read once | events -30 to -40% (C: -0.8 ms; A: -1.6 ms) | C +2, A +9 | Low |
| P2 | **Early-out in `__processEvents`/`__processMouseover`**: if the pointer is outside the widget's (clipped) rect and it was not hovered last frame, skip the 9 click/hold/release/wheel computations; cache "has a clipping ancestor" + the intersected clip rect (invalidate on layout change); skip whole subtrees whose container does not contain the pointer (except dropdown pop-outs) | events a further -30 to -40% (C: -0.6 ms; A: -1.2 ms) | C +1.5, A +7 | Low-medium (hover/exit semantics; the existing 197 tests cover this well) |
| P3 | **Cache descendant lists**: `getDescendants()` returns a cached flat array invalidated by add/remove/tab change/destroy (copy-on-read only for the public method). Replace the per-frame `__gooey_array_clone(__widgets)` with a "pending MOUSE_EXIT" list | idle (B1): 1.22 -> ~0.1 ms; C: -0.3 ms | B +4 | Low |
| P4 | **UIText mouseover without Scribble**: cache the bbox and recompute only when text/format/scale/position/max-width changes | text events 25 -> ~12 us (per 100 texts: -1.3 ms events) | +2 per 100 texts | Low |
| P5 | **Draw-path string/lookup caching**: cache the "[scale,N]" prefix in the manager (updated in `setScale`), cache the composed Scribble string per widget+state, invalidated on text/format/scale change; read scale once per `render()` | render -6 to -9 us on text-bearing widgets (C: -2 to -3 ms) | C +6 | Low |
| P6 | **Slider draw diet**: no per-frame struct, no `setDimensions()` call unless the size really changed, draw min/max/value text through cached strings, only when enabled | slider 66 -> ~35 us (C has 100: -3 ms) | C +7 | Low |
| P7 | **Render micro-cleanups**: skip empty pre/post render callbacks, update bindings only when the bound value changed, reuse one scissor struct (no `gpu_get_scissor()` struct per container), hoist `getScale()` | render -2 to -4 us/widget (C: -1.5 ms) | C +3 | Low |

### Phase 2 - medium risk, biggest wins

| ID | Change | Est. saving | Est. FPS gain | Risk |
|---|---|---|---|---|
| P8 | **Static methods instead of per-instance closures (memory + GC + creation)**. Convert `self.name = function(...)` to `static name = function(...)` in the widget constructors (GML shares statics across all instances; `self` inside is still the calling instance, and local variables were never captured anyway). A script does the mechanical conversion; special cases (`method(self, __builtInBehavior)` chaining, `__UIDimensions`) are fixed by hand. | **Memory per widget -75 to -85%** (e.g. ~20 KB -> ~4 KB; 1000 widgets saves ~15 MB); GC objects 180 -> ~15 per widget; create 38 -> ~8 ms, destroy 63 -> ~15 ms per 500; fewer/shorter GC traversals (less frame-time jitter) | steady-state FPS ~0 to +2 (GC jitter), but removes hitches of 30-60 ms when dialogs open/close | **Medium**: touches ~1,000 methods; subclass overrides and `method()` rebinding must be checked. I will verify with the full test suite and re-run the benchmark, and abort the item if render/events get slower by more than 5% (static lookup walks the inheritance chain) |
| P9 | **Culling**: skip `__draw`/children for widgets whose rectangle is fully outside the clip rect of a clipping ancestor or outside the screen (uses the cached clip rect from P2) | proportional to the hidden fraction: for a scrolled list with 70% hidden, render of that container -70% (A-like panel: 7 -> ~2.5 ms) | scenario-dependent, up to +50 fps on long scroll panels | Medium (must keep dropdown pop-outs, tooltips-like overlays and Text widgets, whose size is only known when drawn, correct) |

### Phase 3 - optional / larger design changes (I would only do these if you want them)

| ID | Change | Est. saving | Trade-off |
|---|---|---|---|
| P10 | **Retained rendering (`panel.setCached(true)`)**: render a static panel into a surface once and blit it; invalidate automatically on any event/value/binding change in that panel (and manually via `invalidate()`) | static panel render: 17.8 ms -> ~0.5 ms for the same 500 widgets (about 10x for a UI that is mostly idle) | **Costs memory** (one surface per cached panel) which pulls against your memory goal; animated sprites, blinking cursor, typists and bindings need invalidation rules. Opt-in, default off |
| P11 | **Pooled/shared clip surface** for `UI_USE_SCISSORS = false`: one reusable surface sized to the largest clipping widget instead of one GUI-sized surface per widget | -8 MB per clipping widget when scissors are off (no effect with the default) | Only matters for users who disable scissors |
| P12 | **Lazy per-widget arrays**: `__events_fired`, `__events_fired_last`, `__callbacks` (17 entries x 3 per widget) allocated lazily/shared "empty" array until first use | ~0.4 KB/widget (about 2%) | Not worth it after P8; listed for completeness, I recommend skipping |

## 4. Projected result (VM, estimates)

| Scenario | Now | After Phase 1 | After Phase 1 + P9 where applicable |
|---|---|---|---|
| A (200 widgets, hovered) | 11.6 ms / ~86 fps | ~6.5 ms / ~150 fps | ~5 ms / ~200 fps |
| B (400 widgets, idle) | 16.2 ms / ~62 fps | ~9.5 ms / ~105 fps | ~8 ms / ~125 fps |
| C (500 widgets, hovered) | 20.2 ms / ~49 fps | ~11-12 ms / ~85 fps | ~8-9 ms / ~110 fps |

Phase 2's P8 additionally brings memory per widget down ~80%, creation/destruction ~4x faster, and shrinks GC work.
Phase 3's P10 would take a static UI to ~1 ms per frame, at the cost of memory.
These are estimates with perhaps +/-30% error; the benchmark suite will give the real figures per item.

## 5. How I would execute it

1. Implement in the order P3 -> P1 -> P2 -> P4 -> P5/P6/P7 -> P8 -> P9, **one commit per item**, each followed by the full test suite (197 tests must stay green) and the benchmark, so every item has a measured before/after in its commit message and in the changelog. Items that do not deliver at least ~40% of their estimate are reverted.
2. Extend the benchmark with a "scroll list" scenario (needed for P9) and a memory scenario for 1000 widgets.
3. No public API changes in Phases 1-2 (`getDescendants()` keeps returning a fresh array copy for callers; internal code uses the cached one).

## 6. Decisions I need from you

1. Approve **Phase 1** (P1-P7) as a whole, or strike items.
2. **P8 (statics)**: approve? It is the biggest memory win and the riskiest edit. If you prefer, do it last or skip it.
3. **P9 (culling)** and **P10 (retained rendering, opt-in)**: yes / no / later.
4. Do you mainly target **YYC** builds? If so I will add a YYC compile smoke test to the plan before P8, since YYC is stricter about statics.

---

## 7. Phase 1 results (implemented)

Measured with `scr_Gooey_Bench` (VM runtime, fastest of 7 batches, paired runs before/after on the same machine). Commits: P3 `763d998b`, P1+P2 `b62fa304`, P4-P7 `12f5a964`.

| Scenario | Events before -> after | Render before -> after | Frame before -> after | FPS (VM) before -> after |
|---|---|---|---|---|
| A: 200 widgets, hovered | 3.59 -> 0.67 ms (-81%) | 6.51 -> 5.13 ms (-21%) | 10.1 -> 5.8 ms | ~99 -> ~172 |
| B: 400 widgets, mouse outside | 1.03 -> 0.04 ms (-96%) | 13.44 -> 11.35 ms (-15%) | 14.5 -> 11.4 ms | ~69 -> ~88 |
| C: 500 widgets, hovered | 1.94 -> 0.34 ms (-82%) | 16.94 -> 14.29 ms (-16%) | 18.9 -> 14.6 ms | ~53 -> ~68 |

Per widget type (render us/widget before -> after): button 23 -> 19.5, text 26.5 -> 19-21, checkbox 29 -> 26, slider 59 -> 46.5, progress bar 10 -> 8.5.
Events per widget (hovered panel): 14-25 us -> 3-4 us (text 25 -> 4).

Versus the estimates: events beat the estimate (-80% vs -60..-70% combined), render fell short (-15..-21% vs about -35%): after the changes the remaining draw cost is
dominated by Scribble's own `draw()` and GPU submission, which the library does not control. P1 alone delivered only about 10% (estimate 30-40%) but it is the enabler
for P2 (cheap per-frame input) and costs nothing, so it was kept. Nothing was reverted.
Not done (from the plan): the binding-only-when-changed sub-item of P7 (it would change behavior when a bound widget is modified by `setText`).

---

## 8. Phase 2 results (P8 static methods, P9 culling) - implemented

VM runtime, fastest-of-7-batches benchmark, same machine. Commits: P8 `72c1cc98`, P9 in the commit that follows it.

### P8 - static methods
606 constructor methods became `static` (shared per constructor instead of one closure per instance). Names captured with `method(self, X)`
(`__builtInBehavior`, `__draw`, `destroy`, `setSprite`, `setImage`) stay per instance, because a child that overrides them as a `static` would make
`method(self, X)` resolve to itself on the second construction (infinite recursion).

| Metric | Before | After |
|---|---|---|
| Own members per widget (button / slider) | 229 / 258 | 86 / 101 |
| GC objects per widget (button / text / checkbox / slider / progress bar) | 188 / 178 / 192 / 200 / 188 | 31 / 20 / 25 / 24 / 23 (-84 to -88%) |
| Create 500 widgets | 38-47 ms | 15-18 ms |
| Destroy 500 widgets | 58-63 ms | 26-30 ms (about half of it from not building the INFO log message when INFO logging is off) |
| Render / events | - | unchanged within noise (no regression from the longer static lookup) |

My estimate of memory per widget (the 15-25 KB I gave before) is based on the object counts, because GameMaker does not expose bytes: it should drop by roughly the same 80%.

**Behavior change (read this):** a widget method that is read as a *value* is now unbound. `var f = button.setText; f("x")` and
`other.setCallback(UI_EVENT.LEFT_CLICK, panel.hide)` no longer work; write `method(panel, panel.hide)` (or wrap it in a function). Calls (`button.setText("x")`),
`with` blocks, inheritance and overrides are unaffected. `setBinding(widget, "getSomething")` is rebound automatically.

### P9 - draw culling
The manager tracks the area visible through the clipping containers drawn so far; a widget (or a whole clipping container's contents) that is completely outside it is not drawn.
Implemented for widgets whose drawn extent is known exactly: `UIButton` (rectangle united with its text), `UIText` (bounding box of the text, scale included), `UIGroup`, `UICanvas`,
with a 24 px margin for Scribble effects. Everything else (sliders, checkboxes, dropdowns, grids, toggle buttons...) is always drawn, because their overhang (labels, pop-ups) is not known in advance.
Pre/post-render callbacks and bindings of culled widgets keep running, only `__draw` is skipped. `UI_CULLING` / `ui_set_culling()` turn it off.

| Scenario | Culling off | Culling on |
|---|---|---|
| 400 buttons + 400 texts in a clipping group, ~6% visible | 21.5-22.4 ms | 11.2-11.5 ms (-47%) |
| 500 widgets, all visible (overhead check) | 14.0 ms | about +1-2% (within noise) |

The gain is smaller than the 70% I estimated: a culled widget still costs its render-loop overhead and the culling test (about 13 us each in the VM), which is about as much as drawing a button.

### How P8 and P9 were verified
* The 203 existing tests (210+ now), unchanged apart from two tests that extracted widget methods as values.
* `scr_Gooey_Scenario`: a scripted scenario that uses every widget type (tabs, nested clipping groups, scrolled content, dropdown pop-ups, scale changes, hide/destroy) and
  records, per step, the MD5 of the rendered GUI surface plus the hover/value state. The 78 fingerprints of the final code are **identical to the code before P8/P9**.
* Culling versus full drawing, pixel for pixel: 40 randomized layouts (buttons with every text anchor/offset/format, texts with wrap/backgrounds, canvases, nested clipping and
  non-clipping groups, scrolled containers, scales 1 and 1.5), plus 10 scenes re-rendered while scrolling. A one-off run with 600 random layouts also matched. Mutation check:
  shrinking the text margin makes 4 of these tests fail.
* Static semantics: tests for repeated construction of every widget type, independent state/callbacks of two instances, subclass overrides, method binding, and a memory regression guard (own members and GC objects per widget).
* Not verified: YYC (the machine's GameMaker has no Visual Studio location configured, so Igor refuses to build it). `tools/run_tests.ps1 -Runtime YYC` is ready for when it is.
