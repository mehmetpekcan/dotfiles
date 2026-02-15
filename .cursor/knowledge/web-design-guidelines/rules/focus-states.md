# Focus States

- Interactive elements need visible focus styles (for example, `focus-visible:ring-*`).
- Never remove outline without a focus replacement (`outline-none` requires equivalent focus indication).
- Prefer `:focus-visible` over `:focus`.
- Use `:focus-within` for compound controls where group focus feedback helps.
