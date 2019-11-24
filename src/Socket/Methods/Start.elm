module Socket.Methods.Start exposing (start)

import Model exposing (Model, getSocketModel, setSocketModel)
import Msg exposing (Msg)
import Socket.Core exposing (sendMessage, sendQueuedMessage)
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
        , sendMessage getArtists
        , sendMessage getPlaylists
        ]


setWebsocketOpen : Update Model Msg
setWebsocketOpen model =
    let
        socket =
            getSocketModel model
    in
    ( setSocketModel model { socket | isOpen = True }, Cmd.none )


processQueue : Update Model Msg
processQueue model =
    let
        socket =
            getSocketModel model
    in
    combineMany
        (List.map sendQueuedMessage socket.messageQueue)
        model
