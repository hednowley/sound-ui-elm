module Main exposing (emptyModel, init, main, subscriptions, update, updateWithStorage, view, viewInput)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Config
import Debug
import Dict
import Html exposing (Html, a, button, div, form, input, section, text)
import Html.Attributes exposing (class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Json.Encode as Encode
import Model exposing (Listeners, Model, PackedModel)
import Msg exposing (..)
import Ports
import Rest.Core as Rest
import Time
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Listener
import Ws.Methods.Handshake
import Ws.Methods.StartScan
import Ws.Msg
import Ws.Request
import Ws.Response


main : Program (Maybe PackedModel) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }



{-
   We want to `setStorage` on every update.
   This function adds the setStorage command for every step of the update function.
-}


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ Ports.setStorage <| Model.pack <| newModel, cmds ]
    )


init : Maybe PackedModel -> Url -> Key -> ( Model, Cmd Msg )
init maybeModel url navKey =
    ( case maybeModel of
        Just packed ->
            Model.unpack packed

        Nothing ->
            emptyModel
    , Cmd.none
    )


emptyModel : Model
emptyModel =
    { username = ""
    , password = ""
    , message = ""
    , isLoggedIn = False
    , token = Nothing
    , websocketTicket = Nothing
    , isScanning = False
    , scanCount = Nothing
    , websocketListeners = Model.Listeners Dict.empty
    , websocketId = 1
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.websocketOpened <| Msg.WsMsg << Ws.Msg.WebsocketOpened
        , Ports.websocketIn <| Msg.WsMsg << Ws.Msg.WebsocketIn
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.OnUrlRequest _ ->
            ( model, Cmd.none )

        OnUrlChange _ ->
            ( model, Cmd.none )

        UsernameChanged name ->
            ( { model | username = name }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            ( model, Cmd.map Msg.RestMsg <| Rest.authenticate model )

        LogOut ->
            ( { model
                | isLoggedIn = False
                , username = ""
                , password = ""
                , token = Nothing
              }
            , Cmd.none
            )

        RestMsg restMsg ->
            let
                ( newModel, cmd ) =
                    Rest.update restMsg model
            in
            ( newModel, Cmd.map Msg.RestMsg cmd )

        WsMsg wsMsg ->
            let
                ( newModel, cmd ) =
                    Ws.update wsMsg model
            in
            ( newModel, Cmd.map Msg.WsMsg cmd )



-- VIEWS


onClickNoBubble : msg -> Html.Attribute msg
onClickNoBubble message =
    Html.Events.custom "click" (Json.Decode.succeed { message = message, stopPropagation = True, preventDefault = True })


view : Model -> Browser.Document Msg
view model =
    { title = "Sound"
    , body =
        [ case model.isLoggedIn of
            False ->
                div [ class "login__wrap" ]
                    [ text model.message
                    , form [ class "login__container" ]
                        [ div [ class "login__logo " ] [ text "Sound." ]
                        , viewInput "username" "text" "Username" model.username UsernameChanged
                        , viewInput "password" "password" "Password" model.password PasswordChanged
                        , button [ onClickNoBubble SubmitLogin, class "login__submit" ] [ text "Login" ]
                        ]
                    ]

            True ->
                div []
                    [ text model.message

                    {- , text ("Your token is: " ++ Maybe.withDefault "?" model.token) -}
                    , text ("Scanned: " ++ (Maybe.withDefault 0 model.scanCount |> String.fromInt))
                    , button [ onClick LogOut ] [ text "Log out" ]
                    , button [ onClick <| Msg.WsMsg Ws.Msg.StartScan ] [ text "Start scan" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []
