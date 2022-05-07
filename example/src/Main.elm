module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Hex
import Html exposing (Html, a, br, button, code, div, form, h3, h4, hr, input, label, node, option, p, pre, select, span, table, td, text, textarea, th, thead, tr)
import Html.Attributes exposing (attribute, class, href, id, max, min, multiple, name, placeholder, property, style, target, type_, value)
import Html.Events exposing (on, onClick)
import Html.Keyed
import Iso8601
import Json.Decode
import Json.Encode
import MyHtml
import NativeForm
import Process
import Task
import Time
import Url


type alias Flags =
    { documentForms : Json.Encode.Value
    }


type alias Model =
    { documentForms : Json.Encode.Value
    , decodedForm : List ( String, NativeForm.Value String )
    , tz : Time.Zone
    , mycheckboxAll : { count : Int, maybeBool : Maybe Bool }
    , myselectmultiAll : { count : Int, maybeBool : Maybe Bool }
    }


type Msg
    = OnFormChange String
    | GotTimezone Time.Zone
    | MyCheckAll Bool
    | MySelectAll Bool


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
    ( { documentForms = flags.documentForms
      , decodedForm = []
      , tz = Time.utc
      , mycheckboxAll = { count = 0, maybeBool = Nothing }
      , myselectmultiAll = { count = 0, maybeBool = Nothing }
      }
    , Cmd.batch
        [ Task.perform GotTimezone Time.here
        , Task.perform OnFormChange (Task.succeed "form123")
        ]
    )


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Input", span [ class "desktop-hint" ] [ text "(output is below)" ] ]
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
                , Html.Keyed.node "div"
                    []
                    [ ( String.fromInt model.myselectmultiAll.count
                      , p []
                            [ select [ name "myselectmulti", multiple True ]
                                [ option [ defaultSelected (Maybe.withDefault False model.myselectmultiAll.maybeBool) ] [ text "Pure" ]
                                , option [ defaultSelected (Maybe.withDefault False model.myselectmultiAll.maybeBool) ] [ text "Type" ]
                                , option [ defaultSelected (Maybe.withDefault False model.myselectmultiAll.maybeBool) ] [ text "Functional" ]
                                ]
                            , div []
                                [ button [ onClick (MySelectAll True), type_ "button", style "font-size" "small" ] [ text "Select all" ]
                                , text " "
                                , button [ onClick (MySelectAll False), type_ "button", style "font-size" "small" ] [ text "Select none" ]
                                ]
                            ]
                      )
                    ]
                ]
            , p []
                [ label [ class "required" ] [ text "Input checkbox" ]
                , Html.Keyed.node "div"
                    []
                    [ ( String.fromInt model.mycheckboxAll.count
                      , p
                            []
                            [ label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Soccer", defaultChecked (Maybe.withDefault False model.mycheckboxAll.maybeBool) ] [], text "Soccer" ]
                            , label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Basketball", defaultChecked (Maybe.withDefault False model.mycheckboxAll.maybeBool) ] [], text "Basketball" ]
                            , label [ class "checkbox" ] [ input [ name "mycheckbox", type_ "checkbox", value "Crochet", defaultChecked (Maybe.withDefault True model.mycheckboxAll.maybeBool) ] [], text "Crochet" ]
                            , button [ onClick (MyCheckAll True), type_ "button", style "font-size" "small" ] [ text "Select all" ]
                            , text " "
                            , button [ onClick (MyCheckAll False), type_ "button", style "font-size" "small" ] [ text "Select none" ]
                            ]
                      )
                    ]
                ]
            , p []
                [ label [ class "required" ] [ text "Input text" ]
                , p []
                    [ input [ name "mytext", type_ "text", defaultValue "hello world" ] []
                    ]
                ]
            , p []
                [ label [] [ text "Textarea" ]
                , p [] [ textarea [ name "mytextarea", defaultValue "lorem\nipsum" ] [] ]
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
                [ label [ class "required" ] [ text "Input url" ]
                , p [] [ input [ name "myurl", type_ "url", defaultValue "http://localhost" ] [] ]
                ]
            , p []
                [ label [] [ text "Input color" ]
                , p [] [ input [ name "mycolor", type_ "color" ] [] ]
                ]
            , p []
                [ label [ class "required" ] [ text "Input date" ]
                , p [] [ input [ name "mydate", type_ "date", defaultValue "2038-01-11" ] [] ]
                ]
            , p []
                [ label [ class "required" ] [ text "Input datetime-local" ]
                , p [] [ input [ name "mydatetime-local", type_ "datetime-local", defaultValue "2038-01-11T15:45" ] [] ]
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
        , hr [] []
        , MyHtml.form MyHtml.Form1
            [ on "change" (Json.Decode.succeed (OnFormChange (MyHtml.stringFromFormId MyHtml.Form1)))
            ]
            [ p []
                [ label []
                    [ text "input"
                    , p [] [ MyHtml.input MyHtml.Name (Just "hello") [] [] ]
                    ]
                ]
            , p []
                [ label []
                    [ text "checkbox"
                    , p [] [ MyHtml.checkbox MyHtml.Choice (Just True) [] [], text "Toggle me" ]
                    ]
                ]
            ]
        , div [ id "debugOutput" ]
            [ h3 [] [ text "About" ]
            , p []
                [ text "This form is managed by Elm with only "
                , a
                    [ href "https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm#L34-L35"
                    , target "_blank"
                    ]
                    [ code [] [ text "type Msg = OnFormChange String" ] ]
                , text ". And happens to be triggered by "
                , a
                    [ href "https://github.com/choonkeat/nativeform/blob/main/example/src/Main.elm#L75"
                    , target "_blank"
                    ]
                    [ code [] [ text "form [ on \"change\" ... ]" ] ]
                , text "."
                ]
            , p []
                [ text "Don't focus on "
                , a [ href "https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onchange" ]
                    [ text "characteristics of form change event" ]
                , text "; you can wire up "
                , code [] [ text "NativeForm" ]
                , text " to any different event handlers instead."
                ]
            , p []
                [ text "See more at "
                , a [ href "https://github.com/choonkeat/nativeform" ] [ text "Github" ]
                , text " or "
                , a [ href "https://package.elm-lang.org/packages/choonkeat/nativeform/latest" ] [ text "Package doc" ]
                ]
            , viewDecodedForm model.tz model.decodedForm
            ]
        ]


viewDecodedForm : Time.Zone -> List ( String, NativeForm.Value String ) -> Html msg
viewDecodedForm tz list =
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
                [ td [] [ text k ]
                , td [] [ text (Debug.toString v) ]
                ]

        parsedInfo =
            parseDontValidate tz list
    in
    div []
        [ h4 [] [ text "Parsed output" ]
        , pre []
            [ text (Debug.toString parsedInfo)
            ]
        , h4 [] [ text "Raw output" ]
        , table []
            (thead []
                [ tr []
                    [ th [] [ text "String" ]
                    , th [] [ text "NativeForm.Value String" ]
                    ]
                ]
                :: (list
                        |> List.filter hasValue
                        |> List.map viewRow
                   )
            )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFormChange formId ->
            ( { model
                | decodedForm =
                    Json.Decode.decodeValue (NativeForm.decoder formId) model.documentForms
                        |> Result.withDefault []
              }
            , Cmd.none
            )

        GotTimezone tz ->
            ( { model | tz = tz }
            , Cmd.none
            )

        MyCheckAll bool ->
            ( { model
                | mycheckboxAll =
                    { maybeBool = Just bool

                    -- Important to always update `count`, otherwise when
                    -- 1. user clicks "check none"
                    -- 2. user checks some checkboxes
                    -- 3. user clicks "check none" again
                    -- since Html.Keyed in (1) and (2) is the same, nothing will appear to happen
                    , count = model.mycheckboxAll.count + 1
                    }
              }
            , Process.sleep 50
                -- Since `mycheckboxAll` only affects dom tree structure
                -- We have to trigger OnFormChange after `view` has taken place
                |> Task.map (always "form123")
                |> Task.perform OnFormChange
            )

        MySelectAll bool ->
            ( { model
                | myselectmultiAll =
                    { maybeBool = Just bool
                    , count = model.myselectmultiAll.count + 1
                    }
              }
            , Process.sleep 50
                |> Task.map (always "form123")
                |> Task.perform OnFormChange
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


{-| a lookup table of fieldname and error message
-}
type alias Errors =
    Dict String String


{-| this is the desired record type we want from our form
-}
type alias ParsedInfo =
    { myselect : Rating
    , myselectmulti : List Characteristic
    , mycheckbox : List Hobby
    , mytext : String

    --
    -- , mytextarea : String
    -- , myemail : Email
    , mynumber : Maybe Int

    -- , myradio : Location
    -- , myrange : Int
    -- , mysearch : String
    -- , mytel : String
    --
    , myurl : Url.Url
    , mycolor : Color
    , mydate : Time.Posix
    , mydatetimelocal : Time.Posix

    -- , mymonth : { year : Int, month : Time.Month }
    -- , mypassword : String
    -- , mytime : { hour : Int, minutes : Int }
    }


type Rating
    = VeryGood
    | Good
    | Okay


ratingFromString : String -> Maybe Rating
ratingFromString s =
    case s of
        "Very good" ->
            Just VeryGood

        "Good" ->
            Just Good

        "Okay" ->
            Just Okay

        _ ->
            Nothing


toRating : Maybe (NativeForm.Value String) -> Result String Rating
toRating maybeV =
    maybeV
        |> Maybe.map (NativeForm.oneMap ratingFromString)
        |> Maybe.andThen (NativeForm.oneWithDefault Nothing)
        |> Result.fromMaybe "invalid rating"


type Characteristic
    = Pure
    | Type
    | Functional


characteristicFromString : String -> Maybe Characteristic
characteristicFromString s =
    case s of
        "Pure" ->
            Just Pure

        "Type" ->
            Just Type

        "Functional" ->
            Just Functional

        _ ->
            Nothing


toCharacteristics : Maybe (NativeForm.Value String) -> Result String (List Characteristic)
toCharacteristics maybeV =
    maybeV
        |> Maybe.map (NativeForm.manyMap (List.filterMap characteristicFromString))
        |> Maybe.map (NativeForm.manyWithDefault [])
        |> Result.fromMaybe "invalid characteristic"


type Hobby
    = Soccer
    | Basketball
    | Crochet


hobbyFromString : String -> Maybe Hobby
hobbyFromString s =
    case s of
        "Soccer" ->
            Just Soccer

        "Basketball" ->
            Just Basketball

        "Crochet" ->
            Just Crochet

        _ ->
            Nothing


toHobbies : Maybe (NativeForm.Value String) -> Result String (List Hobby)
toHobbies maybeV =
    maybeV
        |> Maybe.map (NativeForm.manyMap (List.filterMap hobbyFromString))
        |> Maybe.map (NativeForm.manyWithDefault [])
        |> Result.fromMaybe "invalid hobby"


type Email
    = Email String String


type Location
    = Here
    | There
    | Everywhere


type alias Color =
    { red : Int
    , green : Int
    , blue : Int
    }


colorFromString : String -> Maybe Color
colorFromString str =
    let
        red int =
            modBy 256 (int // 256 // 256)

        green int =
            modBy 256 (int // 256)

        blue int =
            modBy 256 int
    in
    if String.startsWith "#" str then
        Hex.fromString (String.dropLeft 1 str)
            |> Result.map (\i -> Color (red i) (green i) (blue i))
            |> Result.toMaybe

    else
        Nothing


toColor : Maybe (NativeForm.Value String) -> Result String Color
toColor maybeV =
    maybeV
        |> Maybe.map (NativeForm.oneMap colorFromString)
        |> Maybe.andThen (NativeForm.oneWithDefault Nothing)
        |> Result.fromMaybe "invalid color"



--


parseDontValidate : Time.Zone -> List ( String, NativeForm.Value String ) -> Result Errors ParsedInfo
parseDontValidate tz list =
    let
        dict =
            NativeForm.valuesDict list
    in
    Ok ParsedInfo
        |> field "myselect" (toRating (Dict.get "myselect" dict))
        |> field "myselectmulti" (toCharacteristics (Dict.get "myselectmulti" dict))
        |> field "mycheckbox" (toHobbies (Dict.get "mycheckbox" dict))
        |> field "mytext" (toNonEmptyString (Dict.get "mytext" dict))
        |> field "mynumber" (toInt (Dict.get "mynumber" dict))
        |> field "myurl" (toUrl (Dict.get "myurl" dict))
        |> field "mycolor" (toColor (Dict.get "mycolor" dict))
        |> field "mydate" (toTimePosix TypeDate tz (Dict.get "mydate" dict))
        |> field "mydatetime-local" (toTimePosix TypeDateTimeLocal tz (Dict.get "mydatetime-local" dict))


{-| Pipe friendly builder of values that accumulates errors
-}
field :
    comparable
    -> Result err a
    -> Result (Dict comparable err) (a -> b)
    -> Result (Dict comparable err) b
field k newresult result =
    case ( result, newresult ) of
        ( Err errs, Err newerrs ) ->
            Err (Dict.insert k newerrs errs)

        ( Ok _, Err newerrs ) ->
            Err (Dict.fromList [ ( k, newerrs ) ])

        ( Err errs, Ok _ ) ->
            Err errs

        ( Ok res, Ok a ) ->
            Ok (res a)


toNonEmptyString : Maybe (NativeForm.Value String) -> Result String String
toNonEmptyString maybeV =
    maybeV
        |> Maybe.map (NativeForm.oneWithDefault "")
        |> Maybe.withDefault ""
        |> (\str ->
                if String.isEmpty str then
                    Err "cannot be empty"

                else
                    Ok str
           )


toInt : Maybe (NativeForm.Value String) -> Result String (Maybe Int)
toInt maybeV =
    maybeV
        |> Maybe.map (NativeForm.oneMap String.toInt)
        |> Maybe.map (NativeForm.oneWithDefault Nothing)
        |> Result.fromMaybe "invalid number"


toUrl : Maybe (NativeForm.Value String) -> Result String Url.Url
toUrl maybeV =
    maybeV
        |> Maybe.map (NativeForm.oneMap Url.fromString)
        |> Maybe.andThen (NativeForm.oneWithDefault Nothing)
        |> Result.fromMaybe "invalid url"


type DateInputType
    = TypeDate
    | TypeDateTimeLocal


toTimePosix : DateInputType -> Time.Zone -> Maybe (NativeForm.Value String) -> Result String Time.Posix
toTimePosix dateInputType tz maybeV =
    let
        suffix =
            case dateInputType of
                TypeDate ->
                    "T00:00:00Z"

                TypeDateTimeLocal ->
                    ":00Z"

        fixTzHours t =
            Time.millisToPosix 0
                |> Time.toHour tz
                |> (\h -> Time.posixToMillis t - (h * 3600000))
                |> Time.millisToPosix

        fixTzMinutes t =
            -- some timezones are 30 minutes off
            Time.millisToPosix 0
                |> Time.toMinute tz
                |> (\m -> Time.posixToMillis t - (m * 60000))
                |> Time.millisToPosix
    in
    maybeV
        |> Result.fromMaybe "cannot be blank"
        |> Result.map (NativeForm.oneMap (\s -> Iso8601.toTime (s ++ suffix) |> Result.mapError (always ("Invalid date: " ++ s))))
        |> Result.andThen (NativeForm.oneWithDefault (Err "Invalid date"))
        |> Result.map (fixTzHours >> fixTzMinutes)



--


{-| This is a property <https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement>

Not an html attribute <https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input>

-}
defaultValue : String -> Html.Attribute msg
defaultValue str =
    property "defaultValue" (Json.Encode.string str)


defaultChecked : Bool -> Html.Attribute msg
defaultChecked bool =
    property "defaultChecked" (Json.Encode.bool bool)


defaultSelected : Bool -> Html.Attribute msg
defaultSelected bool =
    property "defaultSelected" (Json.Encode.bool bool)
