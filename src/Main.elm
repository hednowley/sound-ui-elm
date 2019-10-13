module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Cache exposing (makeCache, makeModel, tryDecode)
import Config exposing (Config)
import Dict
import Html
    exposing
        ( div
        , text
        )
import Json.Decode
import Loadable exposing (Loadable(..))
import Model exposing (Listeners, Model)
import Msg exposing (Msg(..))
import Ports
import Rest.Core as Rest
import Routing exposing (Route(..))
import Types exposing (Update)
import Updaters exposing (logOut, onUrlChange)
import Url exposing (Url)
import Views.Login
import Views.Root
import Ws.Core as Ws
import Ws.Listeners.ScanStatus
import Ws.Methods.Handshake
import Ws.Methods.Start
import Ws.Methods.StartScan


{-| This is the object passed in by the JS bootloader.
-}
type alias Flags =
    { config : Config
    , model : Maybe Json.Decode.Value
    }


{-| Application entry point.
-}
main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }


{-| A regular update with a "middleware" for storing the model in local storage.
-}
updateWithStorage : Msg -> Update Model Msg
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ Ports.setCache (makeCache newModel), cmds ]
    )


{-| Start the application, passing in the optional serialised model.
-}
init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            makeModel
                (emptyModel url navKey flags.config)
                (tryDecode flags.model)
    in
    ( model, reconnect model )


{-| Tries to connect to the websocket if there is cached token.
-}
reconnect : Model -> Cmd Msg
reconnect model =
    case model.token of
        Loaded token ->
            Rest.getTicket model token

        _ ->
            Cmd.none


emptyModel : Url -> Key -> Config -> Model
emptyModel url key config =
    { key = key
    , username = ""
    , password = ""
    , message = ""
    , token = Absent
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
    , artist = Absent
    , config = config
    , websocketIsOpen = False
    , route = Nothing
    }


{-| Dispatches messages when events are received from ports.
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.websocketOpened <| always WebsocketOpened
        , Ports.websocketClosed <| always WebsocketClosed
        , Ports.websocketIn <| Msg.WebsocketIn
        ]


update : Msg -> Update Model Msg
update msg model =
    case msg of
        OnUrlRequest request ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        OnUrlChange url ->
            onUrlChange url model

        UsernameChanged name ->
            ( { model | username = name }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            Rest.authenticate model.password { model | password = "" }

        LogOut ->
            logOut model

        GotAuthenticateResponse response ->
            Rest.gotAuthenticateResponse response model

        GotTicketResponse response ->
            Rest.gotTicketResponse response model

        -- Start the ticket handshake now that websocket is open
        WebsocketOpened ->
            case model.websocketTicket of
                Just ticket ->
                    Ws.sendMessage
                        (Ws.Methods.Handshake.prepareRequest ticket Ws.Methods.Start.start)
                        model

                Nothing ->
                    ( { model | message = "Can't negotiate websocket as there is no ticket" }, Cmd.none )

        WebsocketClosed ->
            -- Try to reopen the websocket
            ( { model | websocketIsOpen = False }, reconnect model )

        WebsocketIn message ->
            Ws.messageIn message model

        StartScan ->
            Ws.sendMessage
                (Ws.Methods.StartScan.prepareRequest model.scanShouldUpdate model.scanShouldDelete)
                model

        ToggleScanUpdate ->
            ( { model | scanShouldUpdate = not model.scanShouldUpdate }, Cmd.none )

        ToggleScanDelete ->
            ( { model | scanShouldDelete = not model.scanShouldDelete }, Cmd.none )



-- VIEWS


view : Model -> Browser.Document Msg
view model =
    { title = "Sound"
    , body =
        [ div []
            [ div [] [ text model.message ]
            , case model.token of
                Absent ->
                    Views.Login.view model

                Loading ->
                    div [] [ text "Getting token..." ]

                _ ->
                    if model.websocketIsOpen then
                        Views.Root.view model

                    else
                        div [] [ text "Websocket not open" ]
            ]
        ]
    }
