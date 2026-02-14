# Accessibility

- Icon-only buttons need `aria-label`.
- Form controls need `<label>` or `aria-label`.
- Interactive elements need keyboard handlers (`onKeyDown`/`onKeyUp`) when applicable.
- Use `<button>` for actions and `<a>`/`<Link>` for navigation (not `<div onClick>`).
- Images need `alt` (or `alt=""` if decorative).
- Decorative icons need `aria-hidden="true"`.
- Links need discernible text (icon-only links need `aria-label`).
- Use proper semantic landmarks (`header`, `main`, `nav`, `footer`) when relevant.
- Tables need proper header semantics.
- Modal/dialog components need focus management and escape handling.
