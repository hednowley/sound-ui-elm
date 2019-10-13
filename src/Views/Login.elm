module Views.Login exposing (view)

import Html exposing (Html, button, div, form, input, text)
import Html.Attributes exposing (class, disabled, name, placeholder, type_, value)
import Html.Events exposing (onInput)
import Json.Decode
import Model exposing (Model)
import Msg exposing (Msg(..))


view : Model -> Html.Html Msg
view model =
    div [ class "login__wrap" ]
        [ form [ class "login__container" ]
            [ div [ class "login__logo " ] [ text "Sound." ]
            , viewInput "username" "text" "Username" model.username UsernameChanged
            , viewInput "password" "password" "Password" model.password PasswordChanged
            , button [ onClickNoBubble SubmitLogin, class "login__submit", disabled (model.username == "") ] [ text "Login" ]
            ]
        ]


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []


onClickNoBubble : msg -> Html.Attribute msg
onClickNoBubble message =
    Html.Events.custom "click" (Json.Decode.succeed { message = message, stopPropagation = True, preventDefault = True })
