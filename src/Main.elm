module Main exposing (emptyModel, init, main, subscriptions, update, updateWithStorage, view, viewInput)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Debug
import Dict
import Html exposing (Html, a, button, div, form, input, section, span, text)
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
import Ws.Listeners.ScanStatus
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


{-| We want to `setStorage` on every update.
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


unpack : PackedModel -> Model
unpack packed =
    { emptyModel
        | username = packed.username
        , password = packed.password
        , message = packed.message
        , isLoggedIn = packed.isLoggedIn
        , token = packed.token
    }


init : Maybe PackedModel -> Url -> Key -> ( Model, Cmd Msg )
init maybeModel url navKey =
    let
        model =
            case maybeModel of
                Just packed ->
                    unpack packed

                Nothing ->
                    emptyModel
    in
    ( model, reconnect model )


{-| Tries to connect to the websocket if there is cached token.
-}
reconnect : Model -> Cmd Msg
reconnect model =
    case model.token of
        Just token ->
            Rest.getTicket token

        Nothing ->
            Cmd.none


emptyModel : Model
emptyModel =
    { username = ""
    , password = ""
    , message = ""
    , isLoggedIn = False
    , token = Nothing
    , websocketTicket = Nothing
    , isScanning = False
    , scanCount = 0
    , websocketListeners = Model.Listeners Dict.empty
    , notificationListeners =
        Model.NotificationListeners <|
            Dict.fromList
                [ ( "scanStatus", Ws.Listeners.ScanStatus.listener )
                ]
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
            ( model, Rest.authenticate model )

        LogOut ->
            update
                (Msg.WsMsg Ws.Msg.CloseWebsocket)
                { model
                    | isLoggedIn = False
                    , username = ""
                    , password = ""
                    , token = Nothing
                }

        WsMsg wsMsg ->
            let
                ( newModel, cmd ) =
                    Ws.update wsMsg model
            in
            ( newModel, Cmd.map Msg.WsMsg cmd )

        GotAuthenticateResponse response ->
            Rest.gotAuthenticateResponse response model

        GotTicketResponse response ->
            case response of
                Ok r ->
                    update
                        (Msg.WsMsg Ws.Msg.OpenWebsocket)
                        { model | websocketTicket = Just r }

                Err _ ->
                    ( model, Cmd.none )



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
                div [ class "home__wrap" ]
                    [ span [] [ text model.message ]
                    , span [] [ text <| "Scanned: " ++ String.fromInt model.scanCount ]
                    , button [ onClick LogOut ] [ text "Log out" ]
                    , button [ onClick <| Msg.WsMsg Ws.Msg.StartScan ] [ text "Start scan" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []
