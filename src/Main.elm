module Main exposing (emptyModel, init, main, subscriptions, update, updateWithStorage, view, viewInput)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Config
import Dict exposing (Dict)
import Entities.Artist exposing (Artists)
import Html exposing (Html, a, button, div, form, input, label, section, span, text)
import Html.Attributes exposing (checked, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Json.Encode as Encode
import List
import Model exposing (Listeners, Model, PackedModel, decodeMaybePackedModel)
import Msg exposing (Msg(..))
import Ports
import Rest.Core as Rest
import Time
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Listener
import Ws.Listeners.ScanStatus
import Ws.Methods.Handshake
import Ws.Methods.Start
import Ws.Methods.StartScan
import Ws.Request
import Ws.Response


{-| Application entry point.
-}
main : Program (Maybe Json.Decode.Value) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }


{-| Normal update with a "middleware" for storing the model in local storage.
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


{-| Create a model from a packed one.
-}
unpack : PackedModel -> Model
unpack packed =
    { emptyModel | token = packed.token }


{-| Start the application, passing in the optional serialised model.
-}
init : Maybe Json.Decode.Value -> Url -> Key -> ( Model, Cmd Msg )
init maybeModel url navKey =
    let
        model =
            case decodeMaybePackedModel maybeModel of
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
    , scanShouldDelete = False
    , artists = Dict.empty
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.websocketOpened <| always Msg.WebsocketOpened
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
            ( { model | password = "" }, Rest.authenticate model )

        LogOut ->
            ( { model
                | isLoggedIn = False
                , username = ""
                , token = Nothing
              }
            , Ports.websocketClose ()
            )

        GotAuthenticateResponse response ->
            Rest.gotAuthenticateResponse response model

        GotTicketResponse response ->
            Rest.gotTicketResponse update response model

        -- Start the ticket handshake now that websocket is open
        WebsocketOpened ->
            case model.websocketTicket of
                Just ticket ->
                    Ws.sendMessage
                        (Ws.Methods.Handshake.prepareRequest ticket Ws.Methods.Start.start)
                        model

                Nothing ->
                    ( { model | message = "Can't negotiate websocket as there is no ticket" }, Cmd.none )

        WebsocketIn message ->
            Ws.messageIn message model

        OpenWebsocket ticket ->
            ( { model | websocketTicket = Just ticket }, Ports.websocketOpen Config.ws )

        StartScan ->
            Ws.sendMessage
                (Ws.Methods.StartScan.prepareRequest model.scanShouldUpdate model.scanShouldDelete)
                model

        ToggleScanUpdate ->
            ( { model | scanShouldUpdate = not model.scanShouldUpdate }, Cmd.none )

        ToggleScanDelete ->
            ( { model | scanShouldDelete = not model.scanShouldDelete }, Cmd.none )



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
                    , checkboxInput "Delete?" model.scanShouldDelete ToggleScanDelete
                    , button [ onClick StartScan ] [ text "Start scan" ]
                    , viewArtists model.artists
                    ]
        ]
    }


viewArtists : Artists -> Html msg
viewArtists artists =
    div []
        (List.map
            (\a -> span [] [ text a.name ])
            (Dict.values artists)
        )


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []


checkboxInput : String -> Bool -> msg -> Html msg
checkboxInput name isChecked msg =
    label [] [ input [ checked isChecked, type_ "checkbox", onClick msg ] [], text name ]
