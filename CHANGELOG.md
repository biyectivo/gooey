# Changelog

## Unreleased (branch `analysis/deep-review`)

See `ANALYSIS_REPORT.md` for the finding IDs (C-xx, H-xx, M-xx, R-xx, D-xx) referenced below.

### Added
- **Automated test suite** (196 tests) with a headless runner (`tools/run_tests.ps1`), JUnit output, JSDoc consistency check (`tools/check_docs.py`), pre-commit hook and a CI workflow. See `docs/TESTING.md`.
- **Input seam**: `ui_set_input_provider()` / `ui_get_input_provider()`. All pointer/keyboard reads now go through it (R-01).
- **UIToggleButton** widget (`UI_TYPE.TOGGLE_BUTTON`).
- **`UI_EVENT.SUBMIT`**, fired by `UITextBox` when Enter is pressed. `VALUE_CHANGED` on Enter is kept by default for compatibility and can be turned off with `UI_TEXTBOX_ENTER_FIRES_VALUE_CHANGED` / `setEnterFiresValueChanged(false)`.
- UI manager: `getWidgetsByType`, `getWidgetCount`, `getModalPanel`, `isModalOpen`, `getHoveredPanel`, `getHoveredWidget`, `getDraggedWidget`, `getCamera/setCamera`, `bringToFront`, `sendToBack`, `destroyAll`.
- Convenience functions: `ui_get_scale`, `ui_set_scale`, `ui_reset_scale`, `ui_get_widgets_by_type`, `ui_get_widget_count`, `ui_destroy_all`, `ui_is_modal_open`, `ui_get_camera`.
- Widgets: `find(id)`, `getMinWidth/getMinHeight`, `isEffectivelyVisible/Enabled`, `getBoundingBox`, `isHovered`, `isPressed`.
- Panel: `show`, `hide`, `toggle`, `centerOnScreen`, `getCloseButtonAnchor` (the misspelled `getCloseButtonlAnchor` remains as a deprecated alias).
- Spinner: `setWrap/getWrap`. Canvas: `setOwnsSurface/getOwnsSurface` (default `true`, previous behavior).
- Dropdowns close when clicking elsewhere or pressing Escape.

### Fixed
- C-01 `previousTab()`, C-02 `UIOptionGroup.setIndex()` out-of-range, C-03 bounding boxes with Text children / empty containers, C-04 vertical `getInheritLength()`,
  C-05 `removeTab()` (leaked widgets, wrong current tab), C-06 modal switching and clicks leaking to the game while a modal is open, C-07 project compile errors, H-01 GMLive dependency in `sprite_scale()`.
- H-04..H-07 wrong getters (`getTypist`, `getImageBase`, `getImage`) and `setDimensions` argument forwarding.
- H-08 panel resize/drag: minimum size no longer slides the panel; moved panels keep their position on relayout; panel title no longer collides on duplicate IDs.
- H-09 TextBox: read-only no longer blocks `setText()`, unlimited max chars, `setMaxChars` notifies, texts longer than 1024 chars survive editing.
- H-10 duplicate IDs no longer break `UIGrid` / `UISpinner`. H-11 `UISprite` animation stop/wrap and invalid sprites. H-12/H-13 slider & progress-bar degenerate ranges, float steps, scaled drawing.
- H-14 hover feedback respects occlusion/clipping. H-02 (partly) hit-testing uses the scaled size; grid cells no longer double-scale; nested scissors intersect (H-03).
- M-01 invalid `setFocusedPanel` ID, M-04 O(n^2) mouse-exit pass (and MOUSE_EXIT firing every frame), M-05 character filter, M-06 visibility/enabled cascade reaches all tabs, M-08/M-09 destroy/add robustness (cycles, re-parenting),
  M-10 canvas ownership & log spam, M-11 per-frame tab rebuild, M-12 grid cell lookup (array, validation), M-15 fallback `text_renderer`, M-16 min-size docs, tab buttons inside the drag bar are clickable.
- Widget lookup by ID is now O(1).

- Fixed cursor flicker: `UI.__setUICursor` now only records the requested cursor; it is applied once per frame (end of `__processEvents`) and only when changed. `ui_set_cursor` applies immediately.

### Changed
- `GOOEY_NUM_CALLBACKS` is derived from the `UI_EVENT` enum (`UI_EVENT.__COUNT`).
- `UIOptionGroup`/`UIDropdown`/`UISpinner` copy the option arrays they receive.
- `UIPanel.getTitleOffset()` returns the offset (it returned the absolute position).
- `UISlider` drag snapping uses a step grid anchored at the minimum value; a step <= 0 means continuous.
- `UIManager.cleanup()` now also destroys widgets that were never added to a panel.
- JSDoc corrected for `UIGrid`, `UICheckbox`, `UISprite` constructors and several parameters (D-01..D-05, D-09).
