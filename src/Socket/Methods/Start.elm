module Socket.Methods.Start exposing (start)

import Model exposing (Model, getSocketModel, setSocketModel)
import Msg exposing (Msg)
import Socket.Core as Socket
import Socket.Methods.GetArtists exposing (getArtists)
import Socket.Methods.GetPlaylists exposing (getPlaylists)
import Socket.RequestData exposing (RequestData)
import Socket.Types exposing (MessageId)
import Types exposing (Update, combine, combineMany)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start =
    combineMany
        [ setWebsocketOpen
        , processQueue
        , Socket.sendMessage getArtists
        , Socket.sendMessage getPlaylists
        ]


setWebsocketOpen : Update Model Msg
setWebsocketOpen model =
    let
        socket =
            getSocketModel model
    in
    ( setSocketModel model { socket | isOpen = True }, Cmd.none )


sendQueuedMessage : ( MessageId, RequestData Model ) -> Update Model Msg
sendQueuedMessage ( messageId, request ) =
    combine
        ()
        (Socket.sendMessage request)


processQueue : Update Model Msg
processQueue model =
    let
        socket =
            getSocketModel model
    in
    combineMany
        (List.map sendQueuedMessage socket.messageQueue)
        model
