module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Cache exposing (Cache, makeCache, makeModel, tryDecode)
import Config exposing (Config, getWebsocketUrl)
import Dict exposing (Dict)
import Entities.Artist exposing (Artists)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , form
        , input
        , label
        , section
        , span
        , text
        )
import Html.Attributes
    exposing
        ( checked
        , class
        , disabled
        , href
        , name
        , placeholder
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import List
import Loadable exposing (Loadable(..))
import Model exposing (Listeners, Model)
import Msg exposing (Msg(..))
import Ports
import Rest.Core as Rest
import Routing
import String exposing (fromInt)
import Types exposing (Update)
import Url exposing (Url)
import Views.Home
import Views.Login
import Ws.Core as Ws
import Ws.Listener
import Ws.Listeners.ScanStatus
import Ws.Methods.Handshake
import Ws.Methods.Start
import Ws.Methods.StartScan


{-| This is the object passed in by the JS bootloader.
-}
type alias Flags =
    { config : Config, model : Maybe Json.Decode.Value }


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
    , url = url
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
            ( { model | url = url, route = Routing.parseUrl url }, Cmd.none )

        UsernameChanged name ->
            ( { model | username = name }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            Rest.authenticate model.password { model | password = "" }

        LogOut ->
            ( { model | username = "", token = Absent }, Ports.websocketClose () )

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


onClickNoBubble : msg -> Html.Attribute msg
onClickNoBubble message =
    Html.Events.custom "click" (Json.Decode.succeed { message = message, stopPropagation = True, preventDefault = True })


view : Model -> Browser.Document Msg
view model =
    { title = "Sound"
    , body =
        [ case model.token of
            Absent ->
                Views.Login.view model

            Loading ->
                div [] [ text "Getting token..." ]

            _ ->
                case model.websocketIsOpen of
                    True ->
                        Views.Home.view model

                    False ->
                        div [] [ text "Websocket not open" ]
        ]
    }
