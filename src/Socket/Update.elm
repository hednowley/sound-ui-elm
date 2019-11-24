module Socket.Update exposing (emptyModel, reconnect, update)

import Dict
import Loadable exposing (Loadable(..))
import Model exposing (Model, getSocketModel, setSocketModel)
import Msg exposing (Msg(..))
import Rest.Core as Rest
import Socket.Core exposing (messageIn, sendMessage)
import Socket.Listeners.ScanStatus
import Socket.Methods.Handshake
import Socket.Methods.Start
import Socket.Model exposing (Listeners(..), NotificationListeners(..))
import Socket.SocketMsg exposing (SocketMsg(..))
import Socket.Types exposing (MessageId(..))
import Types exposing (Update)


emptyModel : Socket.Model.Model Model
emptyModel =
    { listeners = Listeners Dict.empty
    , notificationListeners =
        NotificationListeners <|
            Dict.fromList
                [ ( "scanStatus", Socket.Listeners.ScanStatus.listener )
                ]
    , messageQueue = []
    , websocketId = MessageId 1
    , isOpen = False
    , ticket = Nothing
    }


update : SocketMsg -> Update Model Msg
update msg model =
    let
        socket =
            getSocketModel model
    in
    case msg of
        -- Start the ticket handshake now that websocket is open
        SocketOpened ->
            case socket.ticket of
                Just ticket ->
                    sendMessage
                        (Socket.Methods.Handshake.prepareRequest ticket Socket.Methods.Start.start)
                        model

                Nothing ->
                    ( { model | message = "Can't negotiate websocket as there is no ticket" }, Cmd.none )

        SocketClosed ->
            -- Try to reopen the websocket
            ( setSocketModel model { socket | isOpen = False }, reconnect model )

        SocketIn message ->
            messageIn message model


{-| Tries to connect to the websocket if there is cached token.
-}
reconnect : Model -> Cmd Msg
reconnect model =
    case model.token of
        Loadable.Loaded _ ->
            Rest.getTicket model

        _ ->
            Cmd.none
