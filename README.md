# NativeForm

Working with `form` in Elm without storing raw form state in Elm, aka "Use the [Platform](https://developer.mozilla.org/en-US/docs/Web/API/Document/forms)".

### Demo

Checkout the demo at https://nativeform.netlify.app and its source code at [example](https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm) subdirectory.

### Getting started

1. Pass the browser `document` into your Elm app through [Flags](https://guide.elm-lang.org/interop/flags.html)

    ```diff
        <script>
            var app = Elm.Main.init({
                node: document.getElementById('myapp'),
                flags: {
                    document: document // <-- important!
                }
            })
        </script>
    ```
1. Store the `document : Json.Encode.Value` from your `Flags` in your `Model`
1. Wire up any (or many) events, e.g. `form [ on "change" OnFormChange ]` or `input [ onInput (always OnFormChange) ]`
1. And call `Json.Decode.decodeValue (NativeForm.decoder formId) model.document` to get the list of form field name and values.

### Notes

1. No matter how many fields you have, you only need one `Msg`
1. Always give your form an `id` value
1. Always give your form fields a `name` value
1. Does not handle `input[type=file]` in a useful manner; manage file uploads by other means.
1. All user input values are either `OneValue String` or `ManyValues (List String)`, including `input[type=number]`; do your own conversion to `Int` or `Time.Posix` etc.
1. When using this library, your form id and field names are "stringly typed". You should use a custom type to manage a fixed set of form fields, but this library does not require you to do so.
1. Do not deal with the `List (String, Value)` returned from `NativeForm.decoder`. Instead, you should parse them into a value of your desired type. e.g.

    ```
    parseDontValidate :
        List ( String, NativeForm.Value )
        -> Result String UserInfo
    ```

    See a [sample `parseDontValidate` implementation](https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm#L344)