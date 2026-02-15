# Content Handling

- Text containers should handle long content (`truncate`, `line-clamp-*`, or `break-words`).
- Flex children often need `min-w-0` to enable truncation.
- Handle empty states; do not render broken UI for empty strings/arrays.
- Assume user-generated content can be very short or very long.
