module Main exposing (..)

import Browser
import Html exposing (Html, a, br, code, div, form, h3, input, label, option, p, pre, select, span, table, td, text, textarea, th, tr)
import Html.Attributes exposing (class, href, id, max, min, multiple, name, placeholder, target, type_, value)
import Html.Events exposing (on, onClick)
import Json.Decode
import Json.Encode
import NativeForm


type alias Flags =
    { document : Json.Encode.Value
    }


type alias Model =
    { document : Json.Encode.Value
    , decodedForm : List ( String, NativeForm.Value )
    }


type Msg
    = OnFormChange String


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { document = flags.document
      , decodedForm = []
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Input" ]
        , span [ class "desktop-hint" ] [ text "output is below" ]
        , form
            [ -- 1.
              -- this `id` must be set in order for `NativeForm.decoder`
              -- to extract form values from the correct form
              id "form123"
            , on "change" (Json.Decode.succeed (OnFormChange "form123"))
            ]
            [ p []
                [ label [] [ text "Select one" ]

                -- 1.
                -- must give your form fields a `name`
                -- but you do not have to hook up `onInput` anymore
                , p []
                    [ select [ name "myselect" ]
                        [ option [] [ text "Very good" ]
                        , option [] [ text "Good" ]
                        , option [] [ text "Okay" ]
                        ]
                    ]
                ]
            , p []
                [ label [] [ text "Select multiple" ]
                , p []
                    [ select [ name "myselectmulti", multiple True ]
                        [ option [] [ text "Pure" ]
                        , option [] [ text "Type" ]
                        , option [] [ text "Functional" ]
                        ]
                    ]
                ]
            , p []
                [ label [] [ text "Input checkbox" ]
                , p []
                    [ label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Soccer" ] [], text "Soccer" ]
                    , label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Basketball" ] [], text "Basketball" ]
                    , label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Crochet" ] [], text "Crochet" ]
                    ]
                ]
            , p []
                [ label [] [ text "Input text" ]
                , p [] [ input [ name "mytext", type_ "text" ] [] ]
                ]
            , p []
                [ label [] [ text "Textarea" ]
                , p [] [ textarea [ name "mytextarea" ] [] ]
                ]
            , p []
                [ label [] [ text "Input email" ]
                , p [] [ input [ name "myemail", type_ "email" ] [] ]
                ]
            , p []
                [ label [] [ text "Input number" ]

                -- 1.
                -- values from `number` fields are still `String`
                , p [] [ input [ name "mynumber", type_ "number" ] [] ]
                ]
            , p []
                [ label [] [ text "Input radio" ]
                , p []
                    [ label [ class "radio" ] [ input [ name "myradio", type_ "radio", value "Here" ] [], text "Here" ]
                    , label [ class "radio" ] [ input [ name "myradio", type_ "radio", value "There" ] [], text "There" ]
                    , label [ class "radio" ] [ input [ name "myradio", type_ "radio", value "Everywhere" ] [], text "Everywhere" ]
                    ]
                ]
            , p []
                [ label [] [ text "Input range" ]

                -- values from `range` fields are still `String`
                , p [] [ input [ name "myrange", type_ "range", Html.Attributes.min "1", Html.Attributes.max "9" ] [] ]
                ]
            , p []
                [ label [] [ text "Input reset" ]

                -- Doesn't do anything by default
                -- Even `onClick OnFormChange` will not do what we need
                -- since the Msg is fired _before_ the form values are
                -- reset in the browser.
                , p [] [ input [ name "myreset", type_ "reset" ] [] ]
                ]
            , p []
                [ label [] [ text "Input search" ]
                , p [] [ input [ name "mysearch", type_ "search" ] [] ]
                ]
            , p []
                [ label [] [ text "Input tel" ]
                , p [] [ input [ name "mytel", type_ "tel" ] [] ]
                ]
            , p []
                [ label [] [ text "Input text" ]
                , p [] [ input [ name "mytext", type_ "text" ] [] ]
                ]
            , p []
                [ label [] [ text "Input url" ]
                , p [] [ input [ name "myurl", type_ "url" ] [] ]
                ]
            , p []
                [ label [] [ text "Input color" ]
                , p [] [ input [ name "mycolor", type_ "color" ] [] ]
                ]
            , p []
                [ label [] [ text "Input date" ]
                , p [] [ input [ name "mydate", type_ "date" ] [] ]
                ]
            , p []
                [ label [] [ text "Input datetime-local" ]
                , p [] [ input [ name "mydatetime-local", type_ "datetime-local" ] [] ]
                ]
            , p []
                [ label [] [ text "Input file" ]

                -- Does not handle `input[file]` values in any useful manner
                , p [] [ input [ name "myfile", type_ "file" ] [] ]
                ]
            , p []
                [ label [] [ text "Input month" ]
                , p [] [ input [ name "mymonth", type_ "month" ] [] ]
                ]
            , p []
                [ label [] [ text "Input password" ]
                , p [] [ input [ name "mypassword", type_ "password" ] [] ]
                ]
            , p []
                [ label [] [ text "Input time" ]
                , p [] [ input [ name "mytime", type_ "time" ] [] ]
                ]
            , p []
                [ label [] [ text "Input week" ]
                , p [] [ input [ name "myweek", type_ "week" ] [] ]
                ]
            ]
        , div [ id "debugOutput" ]
            [ h3 [] [ text "Output" ]
            , p []
                [ text "This form is managed by Elm with only "
                , a
                    [ href "https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm#L23-L24"
                    , target "_blank"
                    ]
                    [ code [] [ text "type Msg = OnFormChange String" ] ]
                , text "."
                ]
            , p []
                [ text "And triggered by "
                , a
                    [ href "https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm#L56"
                    , target "_blank"
                    ]
                    [ code [] [ text "form [ on \"change\" ... ]" ] ]
                , text "; you can wire up a different event handler in your app instead."
                ]
            , p []
                [ text "See more at "
                , a [ href "https://github.com/choonkeat/nativeform" ] [ text "Github" ]
                , text " or "
                , a [ href "https://package.elm-lang.org/packages/choonkeat/nativeform/latest" ] [ text "Package doc" ]
                ]
            , viewDecodedForm model.decodedForm
            ]
        ]


viewDecodedForm : List ( String, NativeForm.Value ) -> Html msg
viewDecodedForm list =
    let
        hasValue ( _, v ) =
            case v of
                NativeForm.OneValue "" ->
                    False

                NativeForm.ManyValues [] ->
                    False

                _ ->
                    True

        viewRow ( k, v ) =
            tr []
                [ th [] [ text k ]
                , td [] [ text (Debug.toString v) ]
                ]
    in
    table []
        (list
            |> List.filter hasValue
            |> List.map viewRow
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFormChange formId ->
            ( { model
                | decodedForm =
                    Json.Decode.decodeValue (NativeForm.decoder formId) model.document
                        |> Result.withDefault []
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
