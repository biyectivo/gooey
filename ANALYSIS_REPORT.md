# gooey — Deep Analysis Report (Milestone 1)

Scope: the library in this repository (`scripts/scr_UI_*`, `objects/UI`, `__Configuration__`) at version `2026.7`, and the public documentation
(`https://biyectivo.com/gooey_documentation/` tutorials + `https://biyectivo.com/gooey_api/` generated API reference, which self-reports `2025.11`).

**Method.** Every library source file was read in full. The documentation site was crawled completely (45 tutorial pages, 17 API pages, ~535 documented methods).
Scripts then cross-checked (a) getter/setter pairs, (b) JSDoc `@method`/`@param` vs. real signatures, (c) the site's API reference vs. the source, and (d) every
method/macro/enum used in tutorial code vs. the library. A headless build with Igor was also run to check that the project compiles.

**Confidence tags.** `[Read]` = confirmed by reading the code (the defect is visible in the source). `[Build]` = confirmed by an actual compile.
`[Likely]` = follows from the code but depends on runtime behaviour that should be confirmed with a test (the Milestone 2 suite covers these).

**Severity.** Critical = crashes/data loss on a normal code path. High = clearly wrong behaviour users will hit. Medium = wrong in specific conditions, or a significant design/perf problem.
Low = polish, naming, docs. Line numbers refer to the repository at the start of this branch.

---

## 0. Executive summary

* The library is feature-rich and consistently styled, but it has **~35 concrete bugs**, most of them in rarely-exercised paths (nobody has called `previousTab()` or `getChildrenBoundingBox*()` on a text child, for example). Several are one-line typos.
* **There are no automated tests**, and the library reads input directly from GameMaker's `device_mouse_*`/`keyboard_*` functions in ~80 places, which makes behaviour impossible to test without an input seam.
* The **`scale` feature is only half implemented**: some widgets multiply by scale, some don't, and some (Grid → child groups) multiply twice.
* **Performance**: every widget instance allocates ~150–250 closures; widget lookup by ID is a linear scan (and is called inside per-frame and per-layout loops); the "mouse exit" pass is O(n²) per frame; several widgets recompute layout in `__draw`.
* **Documentation drift**: the API reference is generated from stale JSDoc: three constructors (`UIGrid`, `UICheckbox`, `UISprite`) are documented with a different signature than the code, one getter is documented under a name that does not exist, and the UI manager (`UI` object), its methods, `setScale`, and all enums/macros are not in the API reference at all. The mkdocs tutorials are, by contrast, accurate (no tutorial call refers to a missing method).
* The checked-in project **does not compile cleanly on the current runtime** because of demo code (`live_auto_call;` in object events), and the library itself contains a `live_auto_call;` (GMLive dependency) inside `sprite_scale()`.

---

## 1. Critical

### C-01  Panel `previousTab()` is broken without wrap (`scr_UI_Panel.gml:1173`) `[Read]`
`_target = max(_target - 1, 0)` reads `_target` before it is assigned (should be `self.__current_tab - 1`). Calling `previousTab()` with the default `_wrap=false` crashes (uninitialised variable) or picks tab 0.

### C-02  `UIOptionGroup.setIndex()` allows an out-of-range index (`scr_UI_OptionGroup.gml:177`) `[Read]`
Clamp upper bound is `array_length(...)` instead of `array_length(...)-1`. `setIndex(999)` stores `length`, and the next draw/`getOptionText()` reads `array[length]` → "index out of range" crash. Affects `UIDropdown` and `UISpinner` (which inherit it). Also an empty options array makes the spinner's `% array_length()` divide by zero.

### C-03  `getChildrenBoundingBoxAbsolute/Relative()` crash for Text children and are wrong otherwise (`scr_UI_Widget.gml:1613–1669`) `[Read]`
For `UI_TYPE.TEXT` children the code calls `_txt.getTextWidth()` but the variable is `_child` (`_txt` is never defined). Additionally: the returned `this_w/this_h` are those of the *last child only*; an empty container returns `x=99999999, width=-199999998`; `_tab` is not in the JSDoc.

### C-04  `UISlider.getInheritLength()` crashes for vertical sliders (`scr_UI_Slider.gml:300`) `[Read]`
References `self.__dimensions.inherit_length`, which doesn't exist (`inherit_height` is the vertical equivalent).

### C-05  `UIPanel.removeTab()` leaks and corrupts state (`scr_UI_Panel.gml:1098–1149`) `[Read]`
* Widgets that live in the removed tab are never destroyed: `array_delete(self.__tabs,…)` just drops the array, leaving them registered in the manager (they keep showing up in `ui_get_widgets()`, keep their IDs reserved, and canvases keep surfaces alive).
* Current-tab bookkeeping only handles "removed tab was the last one". Removing a tab *before* the current one leaves `__current_tab` pointing to a different tab than the one the user was viewing.
* Re-adding a tab afterwards reuses the button ID `…TabButton{n}` of an existing button (silently renamed by the registry).

### C-06  `setModal()` re-enables panels that should stay disabled (`scr_UI_Panel.gml:244–268`) `[Read]`
When panel B becomes modal while A is modal, the loop disables A then calls `A.setModal(false)`, whose "un-modal" branch re-enables *every other panel* (including ones already disabled in this same loop, e.g. earlier in the array). Net result depends on array order; some background panels remain interactive under a modal.
Related `[Likely]`: modal blocking is implemented only by disabling panels, so clicks on the dimmed area hit no panel → `isInteracting()` is `false` → clicks *drill through to the game* while a modal is open.

### C-07  Project does not compile cleanly on current runtime `[Build]`
`obj_New_Demo` Create/Step events contain `live_auto_call;`, which GMLive expands to code using `argument_count`/`return`, illegal in object events: `malformed assignment statement` + `cannot use an argument outside a script`. Igor exits non-zero. (A `.win` is still produced, but CI would be red.)

---

## 2. High

### H-01  Library depends on a GMLive macro (`scr_UI_General.gml:99`) `[Read]`
`sprite_scale()` begins with `live_auto_call;`. Anyone who imports gooey without GMLive (or without its fallback script) gets a compile error in a *library* file. Dev tooling must not be in shipped code.

### H-02  Scale handling is inconsistent / double-applied `[Read]`
`UI.setScale()` is a headline feature (it is not documented on the site), but:
| Widget | Problem |
|---|---|
| Grid → cell `UIGroup` | `__col_width/__row_height` multiply by scale, then `UIGroup.__draw` multiplies width by scale again → **scale²** |
| ProgressBar | `STRETCH` ignores scale for width/height; `REPEAT` steps `_i*_w` unscaled while sprites are scaled (overlap/gaps); `__sprite_progress_anchor`/value-text anchor are not scaled |
| Slider | handle sprite is drawn at scale 1 while its hit box uses `width*scale` (x) and unscaled height (y); `_before/_after` ignore scale; `setDimensions` receives unscaled lengths |
| Dropdown | `_y = _y + _height * scale / 2` where `_height` already includes the scaled text → double scale |
| Button / Text / Checkbox / TextBox | offsets (`text_offset`, `inner_sprite_offset`, margins) are not scaled; Button centres its text with unscaled `width/2` but draws the sprite scaled |
| Mouse-over (`__processMouseover`) | uses unscaled `width/height`, while drag/resize hit-tests in `__processEvents` use scaled ones — widgets are drawn at one size and hit-tested at another |
| `__render` scissor | uses `width*scale` but unscaled `x`; `inherit_width/height` copy unscaled parent size |

### H-03  Nested clipping (scissors) replaces rather than intersects the parent clip (`scr_UI_Widget.gml:1018–1049`) `[Likely]`
With `UI_USE_SCISSORS` a clipping child sets its rectangle absolutely via `gpu_set_scissor_gui`, so a clipped container inside a clipped container (e.g. a clipping Grid cell inside a panel – panels *always* clip) can draw outside the parent's rectangle. `UITextBox.__draw` partly compensates by intersecting manually; the generic path does not.

### H-04  `UIText` getter `getTypist()` returns the background colour (`scr_UI_Text.gml:131`) `[Read]`
### H-05  `UICheckbox.getImageBase()` returns `__image_true` (`scr_UI_Checkbox.gml:131`) `[Read]`
### H-06  `UIWidget.getImage()` returns `self.__image_` (typo → always `undefined`/crash) (`scr_UI_Widget.gml:306`) `[Read]`
### H-07  `UIWidget.setDimensions()` forwards 6 args to a 5-arg `set()` (`scr_UI_Widget.gml:255`) `[Read]`
The documented `_parent` parameter is silently ignored; `__UIDimensions.set`'s own JSDoc calls its 5th parameter `[_parent]` when it is `_relative_to`.

### H-08  `UIPanel` resize clamps width but still moves the origin (`scr_UI_Panel.gml:851–899`) `[Read]`
For `RESIZE_NW/W/SW` (and the Y analogue for `N/NE/NW`) `x`/`y` follow the mouse unconditionally while width/height are clamped to `min_*`, so once the minimum is reached the panel *slides* across the screen. Panel drag also writes `__dimensions.x/y` directly instead of offsets, so any later `calculateCoordinates()` (e.g. `setDimensions()`, anchor change, or a parent resize) snaps the panel back to its original position. Mouse deltas ignore UI scale.

### H-09  `UITextBox` bugs (`scr_UI_TextBox.gml`) `[Read]`
* `setText()` is a no-op when `read_only` — read-only should only block *user* editing, not the program (can't update a read-only log/display field).
* `__max_chars == 99999999` (8 nines) is compared against the 9-nines sentinel `999999999`, so the "unlimited" short-circuit never triggers.
* `setMaxChars()` truncates the text without firing `VALUE_CHANGED` or updating a binding.
* Text is round-tripped through `keyboard_string`, which GameMaker caps at 1024 characters → editing a longer value truncates it.
* Pressing Enter calls `VALUE_CHANGED(text, text)` (old == new). That overloads the event as "submit"; there is no way to distinguish it from a real change (see F-05).
* Enter is processed inside `__draw`, and the keyboard/clipboard model has no selection, copy/paste, home/end with shift, or word-wise delete; in multiline mode Enter always ends editing so you can't type a newline (commented-out code shows the intent).
* `__draw` calls `self.setDimensions()` every frame, re-laying out all children; the constructor *adds* `2*margin` to the requested width/height, so the size you ask for is not the size you get (and the docs don't say so).

### H-10  Duplicate IDs break composite widgets `[Read]`
The registry silently renames duplicate IDs (`Foo` → `Foo1`). Composite widgets build child IDs / look up themselves from the *original* `_id`:
* `UIGrid.__createGrid` creates cells named `"<id>_CellGroup_r_c"` **before** the grid registers; if the grid is renamed, `getCell()/addToCell()` look up `"<new id>_CellGroup…"` → `noone` → crash.
* `UISpinner` captures `spinner: _id` in its button callbacks and calls `get(_id)`, which returns a *different* spinner (the first one with that ID).
* `UIPanel` creates the title `UIText` (`<id>_PanelTitle`) before registering itself, so two panels with the same ID get colliding title IDs.
Callbacks should capture the widget reference, not the string ID.

### H-11  `UISprite` animation issues (`scr_UI_Sprite.gml`) `[Read]`
* `setAnimationSpeed(0)` cannot stop an animation (the existing time source is only replaced when `_speed > 0`).
* Wrap check `__image > sprite_get_number()` should be `>=`; combined with the `__num_frames == animation_length` reset, reverse animation (`animation_step = -1`) or a non-zero `starting_frame` misbehave.
* Constructor guards on `_sprite == undefined` but the library convention for "no sprite" is `noone`/`-1`; `sprite_get_speed(-1)` and `sprite_get_number(-1)` are invalid.
* `_speed` is actually a *time-source period* (bigger = slower) though named "speed".

### H-12  `UIProgressBar` / `UISlider` divide by zero when `min == max` and crash with an invalid progress sprite `[Read]`
`(value-min)/(max-min)` → NaN. The vertical progress anchor calls `sprite_get_height(_sprite_progress)` unconditionally in the constructor. `setMinValue/setMaxValue` don't re-clamp the current value or validate `min <= max`. `REPEAT` mode is implemented only for horizontal bars with a "remaining" sprite; vertical `REPEAT` ignores `sprite_repeat_remaining_progress`.

### H-13  Slider quantisation (`scr_UI_Slider.gml:218–240`) `[Read]`
`__drag_change` defaults to **1**, so a slider with a 0–1 range can only be at 0 or 1 unless you also call `setDragChange()` (not obvious). Step snapping starts from the *current value* rather than from `min`, so with non-aligned minimums or float steps values drift; `drag_change <= 0` makes the `while` loops spin forever. Click-to-step uses `click_change = 2` while scroll/drag use `1`.

### H-14  Hover feedback ignores occlusion and clipping `[Read]`
`UIOptionGroup`, `UIDropdown` and the `UISlider` handle compute hover with a bare `point_in_rectangle` in `__draw`, so they highlight even when another panel is on top of them or the pointer is outside a clipping parent. Click handling uses the dimensions captured during the previous draw (one-frame latency; empty before the first draw).

### H-15  Dropdown UX gaps (`scr_UI_DropDown.gml`) `[Read]`
The list never closes when the user clicks elsewhere, presses Escape, or another panel gets focus; it has no scrolling for long lists, no keyboard navigation, and draws inside its own `__draw`, so siblings drawn later paint *over* the open list.

---

## 3. Medium — bugs and dubious implementations

| ID | Finding | Where |
|---|---|---|
| M-01 | `UI.setFocusedPanel(badID)` → `array_delete(panels, noone, 1)` then pushes `noone` into `__panels` (corrupts the list). | `Create_0.gml:455` |
| M-02 | `getFocusedPanel()` returns `-1` when empty, other "not found" paths return `noone`/`undefined` (`ui_get` → `noone`, `ui_get_currently_*` → `undefined`). Three sentinels for one concept. | `Create_0.gml:449`, `scr_UI_Convenience` |
| M-03 | `__currentlyHoveredPanel` stores an *index* into `__panels`, which is reordered by `setFocusedPanel()` and shrunk by `destroy()`; stale indices are used for "clear events on panel exit" and by `ui_get_currently_hovered_panel()`. | `Create_0.gml` |
| M-04 | "Mouse exit for all widgets" pass is O(n²) per frame (`array_get_index` on a growing list inside a `while`) and re-fetches the widget list on deletion. It also calls the MOUSE_EXIT callback directly, bypassing drill-through. | `Create_0.gml:192–208` |
| M-05 | `__keep_allowed_chars`: when `allow_symbols` is true and `symbols_allowed==""`, *any* rejected character (e.g. letters when `allow_lowercase=false`) is let through by the symbols branch. | `Create_0.gml:345` |
| M-06 | `setVisible()/setEnabled()` cascade by *overwriting* each child's own flag (so re-showing a panel un-hides children you hid individually), and on panels they only reach the **current tab**; other tabs and common widgets keep stale values. Effective visibility should be derived from ancestors. | `scr_UI_Widget.gml:456–479` |
| M-07 | `scroll()` iterates `self.__children` — for panels that is whichever tab is current, but common widgets are unaffected (correct) while the per-tab offsets array is indexed by tab. Scroll state is not clamped to content bounds; there is no scrollbar. | `scr_UI_Widget.gml:1412` |
| M-08 | `destroy()`: logs via `getContainingPanel()` which dereferences `__parent` (crash if a widget that was never `add()`ed is destroyed); resets `__currentlyDraggedWidget` for *any* widget destroyed (cancelling an unrelated drag); `remove()` doesn't reset the removed widget's `__parent`. | `scr_UI_Widget.gml:1557` |
| M-09 | `add()` does not detach the widget from a previous parent (double parent), doesn't reject adding a widget to itself/its descendant, and doesn't validate `_id` is a widget. | `scr_UI_Widget.gml:1471` |
| M-10 | `UICanvas`: the manager and `destroy()` **free the user's surface** (`__surface_id`) — ownership is not the library's; the canvas also logs a WARNING *every frame* while the surface doesn't exist (log spam) and shares `__surface_id` with the clip-surface mechanism. | `Create_0.gml:340`, `scr_UI_Canvas.gml` |
| M-11 | `__redimensionTabs()` runs **every frame** (`MAX` behaviour) and ends with `gotoTab()` which re-sets sprite/image/text/format on every tab button each frame. | `scr_UI_Panel.gml:836, 1016` |
| M-12 | `UIGrid` does `UI.get("<id>_CellGroup_r_c")` (linear scan over *all* widgets) for every cell on every layout update, and layout updates occur on every panel-drag frame. Cells should be held in a 2-D array. Also: proportions are not validated (wrong length → crash; sum ≠ 1 silently leaves gaps); `addNext/addNextRow` silently wrap and overlap when full; no row/column span. | `scr_UI_Grid.gml` |
| M-13 | Layout work in draw: `Checkbox`, `Slider`, `ProgressBar`, `OptionGroup`, `Dropdown`, `Spinner`, `TextBox`, `Sprite` call `setDimensions()` from `__draw`, so their size is unknown (0×0, therefore unclickable) until after the first draw and each call recomputes all descendants. | many |
| M-14 | `UIText` mouse-over rebuilds a Scribble element (`wrap` + `get_bbox`) per text widget per frame; `UIText.__draw` accesses `getParent().getClipsContent()` without a parent null-check. | `scr_UI_Widget.gml:1068`, `scr_UI_Text.gml` |
| M-15 | `text_renderer` (the "GM text renderer" fallback to Scribble in `scr_UI_General`) lacks `wrap()`, `get_bbox()`, typist support and format tags, so switching `UI_TEXT_RENDERER` to it crashes in `UIText`/`UITextBox`. Either complete it or remove it. | `scr_UI_General.gml:205` |
| M-16 | `UIWidget.setMinWidth/Height` doc says "reset it with ≤ 0" but code is `max(1, v)`; both are silently ignored for non-panels; there are no getters. | `scr_UI_Widget.gml:845` |
| M-17 | `Binding` is evaluated in `__render` (draw) and silently overwrites widget state each frame (no VALUE_CHANGED when the *bound* value changes externally); type mismatches `throw` from inside Draw. `setText` on a bound `UIText/UIButton` writes *back* to the bound variable, which throws if the binding is a method (e.g. `UISpinner`'s internal text button). | `scr_UI_Widget.gml:889–1011` |
| M-18 | `Button`/`Text`/`TextBox` drill-through: `LEFT_CLICK` is invoked directly from `__builtInBehavior`, bypassing the drill-through logic that all other events use (and `Textbox`/`Checkbox` do the same). | button/text/textbox |
| M-19 | Config macros: `GOOEY_NUM_CALLBACKS 15` is hard-coded and must equal the number of `UI_EVENT` entries; `UI_MESSAGE_LEVEL` vs `UI_LOG_MESSAGE_LEVEL` naming is confusing; `__Configuration__` has no trailing newline and `.gitignore` lists directories that are in fact tracked (`assets/`, `datafiles/`, `extensions/`, `objects/obj_gmlive`). | misc |
| M-20 | `__game_restart()` destroys all non-persistent instances, then calls `UI.cleanup()`; fine only because `UI` is persistent — brittle and undocumented. `Step_2.gml` is empty. | `scr_Misc` |

---

## 4. Architecture & refactoring candidates

| ID | Proposal | Rationale |
|---|---|---|
| R-01 | **Input seam.** Route all `device_mouse_*`, `mouse_wheel_*`, `keyboard_*` reads through a small provider on the manager (`UI.__input`). | ~80 direct calls; makes the library unit-testable, enables touch/multi-pointer/gamepad cursors and replay. |
| R-02 | **Table-driven event dispatch.** Replace the 14 copy-pasted blocks in `__builtInBehavior` and the 28 drill-through getters/setters with arrays indexed by `UI_EVENT`. | ~400 lines → ~40; the same bug fix is needed in 14 places today. |
| R-03 | **Share methods between instances.** Each constructor assigns hundreds of closures per instance (`UIWidget` alone ≈ 150). Use `static` functions (GM 2022.1+) or move rarely-used accessors to prototypes. | memory, construction time (creating 500 widgets allocates >100k closures). |
| R-04 | **Widget registry with an ID → widget struct** (and per-type lists). | `get/exists/__register` are O(n); `__register` loops until a free suffix is found. |
| R-05 | **Computed effective visibility/enabled** instead of cascading overwrite (see M-06). | correctness + removes recursion on every set. |
| R-06 | **Single scale pipeline**: scale applied once in the dimension solver (`__UIDimensions`), widgets draw in solved pixel space. | removes H-02 as a class. |
| R-07 | **Separate layout from draw**: `__layout()` invalidated by setters; `__draw()` only draws. | M-13, M-11. |
| R-08 | **Overlay/popup layer** for dropdowns, tooltips, context menus (drawn after all panels). | H-15. |
| R-09 | Unify "not found" return values and enforce one naming scheme (`UIDropdown` vs `UI_TYPE.DROPDOWN` vs file `scr_UI_DropDown`; `getCloseButtonlAnchor`). | M-02 |
| R-10 | Split `scr_UI_Widget.gml` (1,676 lines: dimensions, base widget, events, drag, scroll, binding) and `scr_UI_Panel.gml` (1,263: panel + tabs + modal) into cohesive scripts. | maintainability |
| R-11 | Use GM's `#macro`-free configuration object or at least document that config is compile-time; fix `UI_` vs `GOOEY_` macro prefixes. | consistency |

---

## 5. Documentation discrepancies

Three artifacts are compared: **(S)** source code/JSDoc, **(A)** generated API reference site (`/gooey_api`, v2025.11), **(T)** mkdocs tutorials (`/gooey_documentation`).

| ID | Discrepancy |
|---|---|
| D-01 | `UIGrid`: code `UIGrid(_id, _rows, _columns)` and **T** agree; the JSDoc (and therefore **A**) say `UIGrid(_id, _width, _height, _rows, _cols)`. **A is wrong.** |
| D-02 | `UICheckbox`: code `(…, _text, _sprite_true, _sprite_false, _value, _relative_to)`; the JSDoc `@constructor` line and **A** say `_sprite` (single). |
| D-03 | `UISprite`: code `(_id,_x,_y,_sprite,_width,_height,…)`; JSDoc/**A** list `(_id,_x,_y,_width,_height,_sprite,…)`. **T** matches the code. |
| D-04 | `UIPanel.getCloseButtonAnchor()` is documented (S, A) but the implemented name is `getCloseButtonlAnchor` (typo) — calling the documented name fails. |
| D-05 | Implemented but undocumented on A: `UISprite.setAngle`, `UISprite.destroy`, `UIWidget.setScrollOffsetH/V`, `UIWidget.toString`, `text_renderer`, `sprite_scale`. |
| D-06 | **A has no page for the `UI` manager object** (`setScale/getScale/resetScale`, `setLogMessageLevel`, `setMouseDevice`, `getWidgets`, `getPanels`, `getFocusedPanel`, `setFocusedPanel`, `isInteracting`, `render`, `cleanup`, `exists`, `get`, …), nor for enums (`UI_EVENT`, `UI_TYPE`, `UI_RELATIVE_TO`, `UI_ORIENTATION`, `UI_RESIZE_DRAG`, `UI_PROGRESSBAR_RENDER_BEHAVIOR`, `UI_TAB_SIZE_BEHAVIOR`, `UI_MESSAGE_LEVEL`) or macros (`UI_SCROLL_SPEED`, `GOOEY_NUM_CALLBACKS`, `UI_TEXT_RENDERER`). `setScale()` appears nowhere on the site. |
| D-07 | A dropdown entry `doc_scr_Misc.gml.html` → 404. |
| D-08 | A: `UISpinner` `_width/_height` typed `Asset.GMSprite` (should be `Real`); constructor "returns `UIDropdown`"; several parameter descriptions copy/pasted from Dropdown/Checkbox. Return types `All`/`Any`; the pages expose the author's local file paths. |
| D-09 | Source JSDoc errors found by script: `setTextMouseover/Click/Disabled` document `_text` but the parameter is `_text_mouseover/_click/_disabled`; `setBinding` documents `_variable_or_function_name` (actual `_variable_or_method_name`); `__UIDimensions.set` documents `[_parent]` for `_relative_to`; `setTitleFormat` has `@param {String} The inline format tags` (name missing); `setForceBlendmode`/`setShowValue` param names wrong; `resetRowProportions/resetColumnProportions/getCell/getChildrenBoundingBox*` params undocumented; `ui_*` convenience functions have mis-cased `_ID`. |
| D-10 | Version drift: site says latest = 2025.11 (ScribbleDX 9.6.6); code is 2026.7 (ScribbleDX 9.7.3.3); README download link points to 2025.11; a sample log on the site shows "gooey 2025.2.0 / ScribbleDX 9.3.5"; another passage says 9.5.0. |
| D-11 | The tutorials say `setTitleFormat/getTitleFormat` are deprecated since 2025.4 while the code and API doc still present them as normal, and several tutorials still use them. |
| D-12 | Undocumented behaviour: textbox fires `VALUE_CHANGED(text,text)` on Enter; `UITextBox` adds `2*margin` to the requested size; Dropdown/OptionGroup/Spinner share unscaled-vs-scaled quirks; modal blocking semantics. |
| D-13 | Internal site problems: three tutorial pages (`inventory_basic`, `inventory_advanced`, `options_pause_menu`) link to `grids`, `interaction_callbacks`, `panels/tabs` without a trailing slash → ~40 broken relative URLs; `sitemap.xml` is empty; no last-updated dates; the `/api/` mkdocs page is an empty shell. |
| D-14 | Docs say gooey "doesn't handle controller or keyboard navigation natively and probably never will". That is a legitimate scope decision, but the config/FAQ should link to the extension points (callbacks, `setMouseDevice`, the input seam proposed in R-01). |

*Positive:* every method/constructor/macro/enum used by the tutorials' code snippets exists in the library with a compatible signature.

---

## 6. Missing / proposed features

### 6.1 Widgets (priority order)
1. **Tooltip** (`widget.setTooltip(text|callback)`), rendered in the overlay layer (needs R-08). Most requested missing basic.
2. **Scrollbar** (`UIScrollbar`) bound to a container's scroll offset; panels and groups already scroll by wheel but have no indicator, clamping or dragging.
3. **List box / selectable list** (`UIListBox`) with scroll, multi-select, and item-data; the Dropdown list is the same machinery.
4. **Toggle button** (button with persistent value) and **Radio** semantics for `UIOptionGroup` (already similar) — as `UIToggleButton`.
5. **Number input** (`UITextBox` numeric mode: min/max/step, drag-to-adjust) or `UISpinner` numeric mode (the current spinner is option-only).
6. **Separator / Spacer**, **Label with icon**, **Image button** conveniences.
7. **Context menu / menu bar** (needs overlay layer).
8. **Colour picker**, **Tree view**, **Table/DataGrid**, **Notification/toast** (lower priority).
9. **Layout containers**: `UIHBox/UIVBox/UIFlow` (auto-layout with spacing/alignment); `UIGrid` row/column span and auto-sized tracks.

### 6.2 Existing widgets
* **All widgets**: `getMinWidth/Height`, `setMaxWidth/Height`, `getEffectiveVisible/Enabled`, `setTooltip`, `setTabIndex/focus` (opt-in keyboard focus), `find(id)` (descendant search), `getRoot()`, `bringToFront()`, `fadeIn/Out` helpers, `setAlpha` cascading, `isHovered()/isPressed()`, `getBoundingBox()` (absolute rect), `serialize()/deserialize()` for layouts.
* **Panel**: `show()/hide()/toggle()`, `centerOnScreen()`, `setTabEnabled(tab,bool)`, `insertTab(index)`, `getTabByName`, `setCloseOnEscape`, `setMinWidth/Height` as public getters, snap-to-edges/bounds clamping so panels can't be dragged off-screen, collapsible title bar.
* **TextBox**: selection + clipboard (`clipboard_get_text/set_text`), password reveal toggle, validation callbacks, `UI_EVENT.SUBMIT`/`CANCEL` instead of overloading `VALUE_CHANGED`, undo/redo, input filter regex/callback, placeholder colour, `select_all_on_focus`.
* **Slider**: float step (`setStep`), range slider (two handles), tick marks, `UI_EVENT.DRAG_START/END`, value label formatter.
* **ProgressBar**: indeterminate mode, animated tween to value, text formatter.
* **Dropdown**: close-on-outside-click, scroll for long lists, type-ahead, per-item enabled flags, multi-column.
* **Spinner**: wrap on/off, disable arrows at the ends, numeric mode, hold-to-repeat.
* **Checkbox**: tri-state, group exclusivity (radio mode).
* **Sprite**: pause/resume by frame, `animation_end` callback, flip/mirror, tint animation.
* **Canvas**: `setOwnsSurface(bool)`, `setSurface()`, auto-resize, `UI_EVENT` coordinates translated into surface space.
* **Grid**: `getRows/getColumns` exist; add `setRowSpan/ColSpan`, `addRow/removeRow`, fixed-pixel tracks (not just proportions), `clearCell()`.
* **Events**: add `DOUBLE_CLICK`, `DRAG_START/DRAG/DRAG_END`, `FOCUS_GAINED/LOST`, `KEY_PRESSED`, `SUBMIT`, `SHOWN/HIDDEN`, with `(widget, event_data)` callback arguments so one callback function can serve many widgets.

### 6.3 UI manager (`UI` object)
`ui_set_scale/ui_get_scale/ui_reset_scale` convenience wrappers (currently none); `getCamera/setCamera` on the object (not only `ui_set_camera`); `destroyAll()` / `ui_destroy_all()`; `getWidgetsByType(type)`; `getHoveredWidget()/getHoveredPanel()/getDraggedWidget()` returning refs (not indices); `getModalPanel()`/`isModalOpen()`; `bringToFront(id)`/`sendToBack(id)`; `setEnabled(bool)` global input gate and `setVisible(bool)` global hide; `update()` step hook for manual (non-object) driving; `getWidgetCount()`; `getInputProvider()/setInputProvider()` (R-01); event bus (`UI.on("widget_destroyed", fn)`); `getFrameStats()` (hover/event counts for profiling); theme/skin object (default sprites + text formats per widget type) so each constructor doesn't need sprite arguments; localisation hook (`UI.setTextTransform(fn)`); `setLogMessageLevel` accepting a log sink callback instead of only `show_debug_message`.

---

## 7. Tooling, packaging and project hygiene

* **No tests, no CI.** Proposed in Milestone 2.
* `builds/` holds 29 MB of committed `.yymps` artifacts, most of them obsolete (2023–2024); use GitHub Releases (the README already does).
* `assets/` (7.6 MB of third-party PNGs), `datafiles/GMLive` and `extensions/GMLive_fallback` are committed although `.gitignore` lists them; third-party licences for the art assets are not tracked.
* `obj_New_Demo` is an unfinished scratch object; `obj_Old_Demo` (1,015 lines in one Step event) is the actual showcase; both live in the library project. Split the demo from the library package (separate folder/project, or exclude from the `.yymps`).
* Version number lives in a macro (`UI_LIBRARY_VERSION`) and in file names/README; add a single `CHANGELOG.md`.
* README is minimal and links the 2025.11 release.
* The headless build needs a prefab (`io.gamemaker.sdfshaders`, pulled in by the Scribble dependency) that Igor looks up in `<project>/prefabs`; this is worth knowing for CI (handled in Milestone 2's runner).

---

## 8. Suggested order of work (feeds Milestone 2)

1. Make the project build (C-07, H-01).
2. Add the input seam and the automated test harness (R-01), then pin current behaviour with tests, including failing tests for the bugs above.
3. Fix bugs C-01…C-06, H-04…H-14, M-01…M-12, D-01…D-05, D-09.
4. Performance/refactors that tests protect (R-02, R-04, M-04, M-12, M-14).
5. New manager/widget methods that are cheap and testable (§6.2/6.3 subset) and new widgets whose logic is unit-testable.
6. Docs: JSDoc fixes, manager page, enum/macro reference, changelog; plan the doc-site regeneration.

---

## 9. Implementation status (Milestone 2)

Tested by `tools/run_tests.ps1` (196 tests, 624 assertions, all passing) plus `tools/check_docs.py`. "Partial" items are explained in the notes.

| Status | Items |
|---|---|
| **Fixed + tested** | C-01 C-02 C-03 C-04 C-05 C-06 C-07 · H-01 H-04 H-05 H-06 H-07 H-08 H-10 H-11 H-13 · M-01 M-04 M-05 M-08 M-09 M-10 M-11 M-15 M-16 · R-01 R-04 · D-04 D-09 (source JSDoc) |
| **Fixed, partly tested** | H-03 (nested scissors intersect; needs a visual check in a real nested-clip layout) · H-12 (zero ranges, missing sprite; vertical REPEAT now draws remaining sprite) · H-14 (hover gating uses the event-processing result) · M-06 (cascade reaches all tabs/common widgets; the "derived" model is available as `isEffectivelyVisible/Enabled` but setters still overwrite) · M-12 (cell array, validation; no spans) · M-13 (checkbox size known at creation; other widgets still size in draw) |
| **Partial** | H-02 scale (hit-testing, grid cells, slider handle, progress bar, panel drag/resize now scale-aware; button/checkbox/textbox *offsets* are still unscaled) · H-09 (see CHANGELOG; selection/clipboard, margin semantics and multiline Enter are **not** done) · H-15 (closing on outside click/Escape done; scrolling lists, keyboard navigation and an overlay layer are not) · M-02/M-03 (conversions documented/index kept in sync on reorder; sentinel values unchanged to avoid breaking callers) |
| **Not done** | M-07 scroll clamping/scrollbar · M-14 text mouse-over allocation · M-17 binding-in-draw redesign · M-18 · M-19 (only `GOOEY_NUM_CALLBACKS` derived; `.gitignore` extended) · M-20 · R-02 R-03 R-05..R-11 · all new *visual* widgets except UIToggleButton (Tooltip, Scrollbar, ListBox, ... need the overlay layer R-08 and visual verification) |
| **Docs** | Source JSDoc fixed for D-01..D-05, D-09; **the hosted API reference and tutorials must be regenerated/updated by the maintainer** (D-06..D-08, D-10..D-14 are site-side). `tools/check_docs.py` prevents the JSDoc from drifting again. |

### Behavior changes worth a release note
* `UIPanel.getTitleOffset()` now returns offsets (was absolute position).
* `UISlider` default drag step is still 1, but snapping is anchored at the minimum value.
* `UIManager.cleanup()` also destroys orphan widgets.
* Canvas still frees its surface by default (`setOwnsSurface(false)` opts out).
* TextBox still fires `VALUE_CHANGED` on Enter by default; use `SUBMIT` in new code.
