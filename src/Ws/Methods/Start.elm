module Ws.Methods.Start exposing (start)

import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update, combine)
import Ws.Core as Ws
import Ws.Methods.GetArtists exposing (getArtists)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start =
    combine setWebsocketOpen (Ws.sendMessage getArtists)


setWebsocketOpen : Update Model Msg
setWebsocketOpen model =
    ( { model | websocketIsOpen = True }, Cmd.none )
