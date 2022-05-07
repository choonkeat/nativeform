module MyHtml exposing
    ( FieldName(..)
    , FormId(..)
    , checkbox
    , form
    , input
    , option
    , radio
    , select
    , stringFromFieldName
    , stringFromFormId
    , textarea
    )

import Html
import Html.Attributes
import Json.Encode
import NativeForm


type FormId
    = Form1
    | Form2


stringFromFormId : FormId -> String
stringFromFormId a =
    case a of
        Form1 ->
            "Form1"

        Form2 ->
            "Form2"


type FieldName
    = Name
    | Choice


stringFromFieldName : FieldName -> String
stringFromFieldName a =
    case a of
        Name ->
            "Name"

        Choice ->
            "Choice"


customized : NativeForm.CustomizedHtml FormId FieldName (Html.Attribute msg) (Html.Html msg)
customized =
    NativeForm.buildCustomizedHtml
        { form = Html.form
        , input = Html.input
        , textarea = Html.textarea
        , option = Html.option
        , select = Html.select
        , property = Html.Attributes.property
        , type_ = Html.Attributes.type_
        }
        { formIdAttr = stringFromFormId >> Html.Attributes.id
        , fieldNameAttr = stringFromFieldName >> Html.Attributes.name
        }


form : FormId -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
form =
    customized.form


input : FieldName -> Maybe String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
input =
    customized.input


textarea : FieldName -> Maybe String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
textarea =
    customized.textarea


radio : FieldName -> Maybe Bool -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
radio =
    customized.radio


checkbox : FieldName -> Maybe Bool -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
checkbox =
    customized.checkbox


option : Maybe Bool -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
option =
    customized.option


select : FieldName -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
select =
    customized.select
