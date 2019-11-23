module Socket.Update exposing (reconnect, update)

import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Rest.Core as Rest
import Socket.Core exposing (messageIn, sendMessage)
import Socket.Methods.Handshake
import Socket.Methods.Start
import Socket.SocketMsg exposing (SocketMsg(..))
import Types exposing (Update)


update : SocketMsg -> Update Model Msg
update msg model =
    case msg of
        -- Start the ticket handshake now that websocket is open
        SocketOpened ->
            case model.websocketTicket of
                Just ticket ->
                    sendMessage
                        (Socket.Methods.Handshake.prepareRequest ticket Socket.Methods.Start.start)
                        model

                Nothing ->
                    ( { model | message = "Can't negotiate websocket as there is no ticket" }, Cmd.none )

        SocketClosed ->
            -- Try to reopen the websocket
            ( { model | websocketIsOpen = False }, reconnect model )

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
