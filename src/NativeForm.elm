module NativeForm exposing
    ( Value(..)
    , decoder, valuesDict, valuesAppend, oneMap, manyMap, oneWithDefault, manyWithDefault
    )

{-| Using browser `document` to decode the current values of forms at anytime.


## Types

@docs Value


## Helper

@docs decoder, valuesDict, valuesAppend, oneMap, manyMap, oneWithDefault, manyWithDefault

-}

import Dict exposing (Dict)
import Json.Decode


{-| Values from form fields are either `String` or `List String`

e.g. values for `input [ type_ "number" ] []` will still be a `String` since
and is entirely up to your application to convert and validate it with
`String.toInt` or `String.toFloat`

-}
type Value a
    = OneValue a
    | ManyValues (List a)


{-|

    OneValue 3
    |> oneMap ((+) 2)
    --> OneValue 5

    ManyValues [ 3 ]
    |> oneMap ((+) 2)
    --> ManyValues []

-}
oneMap : (a -> b) -> Value a -> Value b
oneMap f value =
    case value of
        OneValue a ->
            OneValue (f a)

        ManyValues _ ->
            ManyValues []


{-|

    OneValue 3
    |> manyMap ((++) [ 2 ])
    --> ManyValues []

    ManyValues [ 3 ]
    |> manyMap ((++) [ 2 ])
    --> ManyValues [ 2, 3 ]

-}
manyMap : (List a -> List b) -> Value a -> Value b
manyMap f value =
    case value of
        OneValue _ ->
            ManyValues []

        ManyValues list ->
            ManyValues (f list)


{-|

    OneValue 42
    |> oneWithDefault 3
    --> 42

    ManyValues [42]
    |> oneWithDefault 3
    --> 3

-}
oneWithDefault : a -> Value a -> a
oneWithDefault default value =
    case value of
        OneValue a ->
            a

        ManyValues _ ->
            default


{-|

    OneValue 42
    |> manyWithDefault [3]
    --> [3]

    ManyValues [42]
    |> manyWithDefault [3]
    --> [42]

-}
manyWithDefault : List a -> Value a -> List a
manyWithDefault default value =
    case value of
        OneValue _ ->
            default

        ManyValues list ->
            list


{-| Given 2 Value, return a ManyValues

    valuesAppend (OneValue "1") (OneValue "a")
    --> ManyValues ["1","a"]

    valuesAppend (OneValue "1") (ManyValues ["a","b"])
    --> ManyValues ["1","a","b"]

    valuesAppend (ManyValues ["1","2"]) (ManyValues ["a","b"])
    --> ManyValues ["1","2","a","b"]

    valuesAppend (ManyValues ["1","2"]) (OneValue "a")
    --> ManyValues ["1","2","a"]

-}
valuesAppend : Value a -> Value a -> Value a
valuesAppend a b =
    case ( a, b ) of
        ( OneValue x, OneValue y ) ->
            ManyValues [ x, y ]

        ( OneValue x, ManyValues y ) ->
            ManyValues (x :: y)

        ( ManyValues x, OneValue y ) ->
            ManyValues (x ++ [ y ])

        ( ManyValues x, ManyValues y ) ->
            ManyValues (x ++ y)


{-| Given a list of key values, combine the values of duplicate keys

    import Dict exposing (Dict)

    valuesDict
        [ (1, OneValue "1")
        , (2, OneValue "a")
        , (2, ManyValues ["b","c"])
        , (3, ManyValues ["yes","no"])
        ]
    --> Dict.fromList
    -->     [ (1, OneValue "1")
    -->     , (2, ManyValues ["a","b","c"])
    -->     , (3, ManyValues ["yes","no"])
    -->     ]

-}
valuesDict : List ( comparable, Value a ) -> Dict comparable (Value a)
valuesDict list =
    List.foldl
        (\( k, v ) ( dict, seen ) ->
            if Dict.member k seen then
                ( Dict.update k
                    (\maybeV ->
                        Just (valuesAppend (Maybe.withDefault (ManyValues []) maybeV) v)
                    )
                    dict
                , seen
                )

            else
                ( Dict.insert k v dict
                , Dict.insert k () seen
                )
        )
        ( Dict.empty, Dict.empty )
        list
        |> Tuple.first


{-| Given the `id` attribute of a `<form>` tag, we can decode the current
form values into a List of key values.

    view model =
        -- form with `id` attribute
        form [ id "edituserform123" ]
            -- fields with `name` attribute
            []

    update msg model =
        ( { model
            | formFields =
                -- decode model.document to obtain a list of
                -- form field values anytime
                model.document
                    |> Json.Decode.decodeValue (NativeForm.decoder "edituserform123")
                    |> Result.withDefault []
          }
        , Cmd.none
        )

NOTE: We are returning a `List` instead of `Dict` because on form submit, duplicate
names are preserved. So we are preserving them here too.

<https://developer.mozilla.org/en-US/docs/Web/API/Document/forms>
<https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/elements>

-}
decoder : String -> Json.Decode.Decoder (List ( String, Value String ))
decoder formId =
    Json.Decode.at [ "forms", formId, "elements" ] (decodeArrayish decodeFormElement)
        |> Json.Decode.map List.concat


{-| Replacement for when the Array-ish value is not a real Array :. we cannot use `Json.Decode.list`

document.forms.someFormId contains a HTMLFormElement
<https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement>

document.forms.someFormId.elements contains a HTMLFormControlsCollection
<https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormControlsCollection>

Though they behave like an array with `.length` property and `forms[index]` accessors,
they aren't array and cannot be decoded with `Json.Decode.list`

-}
decodeArrayish : (Int -> Json.Decode.Decoder a) -> Json.Decode.Decoder (List a)
decodeArrayish indexedDecoder =
    Json.Decode.field "length" Json.Decode.int
        |> Json.Decode.andThen (decodeArrayish_help indexedDecoder 0)


decodeArrayish_help : (Int -> Json.Decode.Decoder a) -> Int -> Int -> Json.Decode.Decoder (List a)
decodeArrayish_help indexedDecoder index length =
    if index >= length then
        Json.Decode.succeed []

    else
        Json.Decode.map2 (::)
            (indexedDecoder index)
            (decodeArrayish_help indexedDecoder (index + 1) length)


{-| Primary decoder for each item in HTMLFormControlsCollection
-}
decodeFormElement : Int -> Json.Decode.Decoder (List ( String, Value String ))
decodeFormElement index =
    Json.Decode.oneOf
        [ Json.Decode.field (String.fromInt index) decodeMultiSelect
            |> Json.Decode.map (Tuple.mapSecond ManyValues >> List.singleton)
        , Json.Decode.field (String.fromInt index) decodeChecked
            |> Json.Decode.map (List.map (Tuple.mapSecond OneValue))
        , Json.Decode.field (String.fromInt index) decodeRadio
            |> Json.Decode.map (List.map (Tuple.mapSecond OneValue))
        , Json.Decode.field (String.fromInt index) decodeInput
            |> Json.Decode.map (Tuple.mapSecond OneValue >> List.singleton)
        ]


decodeMultiSelect : Json.Decode.Decoder ( String, List String )
decodeMultiSelect =
    -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/select#attr-multiple
    Json.Decode.field "multiple" Json.Decode.bool
        |> Json.Decode.andThen
            (\b ->
                if b then
                    Json.Decode.map2 Tuple.pair
                        (Json.Decode.field "name" Json.Decode.string)
                        -- https://developer.mozilla.org/en-US/docs/Web/API/HTMLSelectElement/options
                        (Json.Decode.field "options" (decodeArrayish decodeMultiSelectOption)
                            |> Json.Decode.map (List.filterMap identity)
                        )

                else
                    Json.Decode.fail "expecting select[multiple=true] but was false"
            )


decodeMultiSelectOption : Int -> Json.Decode.Decoder (Maybe String)
decodeMultiSelectOption index =
    -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/option#attr-selected
    Json.Decode.at [ String.fromInt index, "selected" ] Json.Decode.bool
        |> Json.Decode.andThen
            (\b ->
                if b then
                    Json.Decode.at [ String.fromInt index, "value" ] Json.Decode.string
                        |> Json.Decode.map Just

                else
                    Json.Decode.succeed Nothing
            )


decodeChecked : Json.Decode.Decoder (List ( String, String ))
decodeChecked =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\inputType ->
                case inputType of
                    -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types
                    "checkbox" ->
                        -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#checked
                        Json.Decode.field "checked" Json.Decode.bool
                            |> Json.Decode.andThen
                                (\b ->
                                    if b then
                                        Json.Decode.map2 (\k v -> [ ( k, v ) ])
                                            (Json.Decode.field "name" Json.Decode.string)
                                            (Json.Decode.field "value" Json.Decode.string)

                                    else
                                        Json.Decode.succeed []
                                )

                    _ ->
                        Json.Decode.fail ("expecting input[type=checkbox] but was input[type=" ++ inputType ++ "]")
            )


decodeRadio : Json.Decode.Decoder (List ( String, String ))
decodeRadio =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\inputType ->
                case inputType of
                    -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types
                    "radio" ->
                        -- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#checked
                        Json.Decode.field "checked" Json.Decode.bool
                            |> Json.Decode.andThen
                                (\b ->
                                    if b then
                                        Json.Decode.map2 (\k v -> [ ( k, v ) ])
                                            (Json.Decode.field "name" Json.Decode.string)
                                            (Json.Decode.field "value" Json.Decode.string)

                                    else
                                        Json.Decode.succeed []
                                )

                    _ ->
                        Json.Decode.fail ("expecting input[type=radio] but was input[type=" ++ inputType ++ "]")
            )


decodeInput : Json.Decode.Decoder ( String, String )
decodeInput =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "value" Json.Decode.string)
