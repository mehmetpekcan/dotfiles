# Anti-patterns (Flag These)

- Disabling zoom (`user-scalable=no`, `maximum-scale=1`).
- Blocking paste on inputs.
- Using `transition: all`.
- Removing focus outlines without replacement.
- Inline click-based navigation without proper links.
- Click handlers on non-semantic elements (`div`/`span`) instead of buttons.
- Missing loading/disabled state during async actions.
- Hardcoded date/number formats.
- Layout-thrashing reads mixed with writes in tight loops.
- Large unvirtualized lists.
- Inputs without labels.
- Icon-only actions without accessible names.
