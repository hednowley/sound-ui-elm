module Main exposing (emptyModel, init, main, subscriptions, update, updateWithStorage, view, viewInput)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Config
import Debug
import Dict
import Html exposing (Html, a, button, div, form, input, section, span, label, text)
import Html.Attributes exposing (class, href, name, placeholder, type_, value, checked)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Json.Encode as Encode
import Model exposing (Listeners, Model, PackedModel)
import Msg exposing (Msg(..))
import Ports
import Rest.Core as Rest
import Time
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Listener
import Ws.Listeners.ScanStatus
import Ws.Methods.Handshake
import Ws.Methods.StartScan
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
        , scanShouldUpdate = packed.scanShouldUpdate
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
    , scanShouldUpdate = False
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.websocketOpened <| Msg.WebsocketOpened
        , Ports.websocketIn <| Msg.WebsocketIn
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnUrlRequest _ ->
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
                CloseWebsocket
                { model
                    | isLoggedIn = False
                    , username = ""
                    , password = ""
                    , token = Nothing
                }

        GotAuthenticateResponse response ->
            Rest.gotAuthenticateResponse response model

        GotTicketResponse response ->
            Rest.gotTicketResponse update response model

        WebsocketOpened _ ->
            case model.websocketTicket of
                Just ticket ->
                    Ws.sendMessage model (Ws.Methods.Handshake.prepareRequest ticket)

                Nothing ->
                    ( model, Cmd.none )

        WebsocketIn message ->
            ( Ws.messageIn message model, Cmd.none )

        OpenWebsocket ->
            ( model, Ports.websocketOpen Config.ws )

        CloseWebsocket ->
            ( model, Ports.websocketClose () ) 

        StartScan ->
            Ws.sendMessage model (Ws.Methods.StartScan.prepareRequest model.scanShouldUpdate)

        ToggleScanUpdate ->
            ( { model | scanShouldUpdate = not model.scanShouldUpdate}, Cmd.none ) 




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
                    , checkboxInput "Update?" model.scanShouldUpdate ToggleScanUpdate
                    , button [ onClick StartScan ] [ text "Start scan" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []

checkboxInput : String -> Bool -> msg -> Html msg
checkboxInput name isChecked msg =
    label [] [ input [ checked isChecked, type_ "checkbox", onClick msg ] [], text name ] 
