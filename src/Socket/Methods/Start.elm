module Socket.Methods.Start exposing (start)

import Model exposing (Model)
import Msg exposing (Msg)
import Socket.Core as Socket
import Socket.Methods.GetArtists exposing (getArtists)
import Socket.Methods.GetPlaylists exposing (getPlaylists)
import Types exposing (Update, combine)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start =
    combine
        (combine setWebsocketOpen (Socket.sendMessage getArtists))
        (Socket.sendMessage getPlaylists)


setWebsocketOpen : Update Model Msg
setWebsocketOpen model =
    ( { model | websocketIsOpen = True }, Cmd.none )
