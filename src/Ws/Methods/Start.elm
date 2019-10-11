module Ws.Methods.Start exposing (start)

import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update, combine)
import Ws.Core as Ws
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Methods.GetArtists exposing (getArtists)
import Ws.Types exposing (RequestData)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start =
    combine setWebsocketOpen (Ws.sendMessage getArtists)


setWebsocketOpen : Update Model Msg
setWebsocketOpen model =
    ( { model | websocketIsOpen = True }, Cmd.none )
