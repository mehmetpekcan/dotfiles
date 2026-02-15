# Forms

- Inputs need `autocomplete` and meaningful `name`.
- Use correct `type` (`email`, `tel`, `url`, `number`) and `inputmode`.
- Never block paste (`onPaste` + `preventDefault`).
- Labels must be clickable (`htmlFor` or wrapping control).
- Disable spellcheck on emails, codes, and usernames when appropriate.
- Checkbox/radio label and control should share one hit target (no dead zones).
- Provide inline validation with actionable error messages.
- Preserve user input on validation errors.
- Submit buttons should indicate loading/disabled states during submission.
- Use descriptive placeholder text only as hint, not as a label replacement.
- Group related controls with semantic structure (`fieldset`, `legend`) where relevant.
