# Performance

- Virtualize large lists (for example, >50 items).
- Avoid layout reads in render (`getBoundingClientRect`, `offsetHeight`, `offsetWidth`, `scrollTop`).
- Batch DOM reads and writes to avoid layout thrashing.
- Prefer uncontrolled inputs when possible; controlled inputs must stay cheap per keystroke.
- Add `preconnect` for critical CDN/asset domains.
- Preload critical fonts and use `font-display: swap`.
