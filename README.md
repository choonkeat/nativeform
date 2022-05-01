# NativeForm

[choonkeat/formdata](https://elm-formdata.netlify.app) without managing storing state, aka "Use the [Platform](https://developer.mozilla.org/en-US/docs/Web/API/Document/forms)".

---

### Notes

This is work in progress. Ideally, we'd like to have a [parseDontValidate function](https://github.com/choonkeat/formdata#submit) convention like [choonkeat/formdata](https://elm-formdata.netlify.app).

- User input values are either `OneValue String` or `ManyValues (List String)`.
- `input[type=number]` value is also `OneValue String`. Use `String.toInt` or `String.toFloat` inside your own `parseDontValidate` function
- `input[type=file]` is not handled. Manage file uploads by other means.
- `NativeForm.decoder` returns a `List` instead of `Dict` because in regular form submit, duplicate names are preserved. So we are preserving them here too.