# Hydration Safety

- Inputs with `value` should also provide `onChange` (or use `defaultValue` for uncontrolled).
- Date/time rendering should avoid server-client mismatch where possible.
- Use `suppressHydrationWarning` only in narrow, justified cases.
