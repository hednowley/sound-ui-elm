module Ws.Types exposing (RequestData)

import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg)
import Ws.Listener


{-| Describes a message to send down the websocket and optionally how to handle a response to that message.
-}
type alias RequestData =
    { method : String
    , params : Maybe Json.Encode.Value
    , listener : Maybe (Ws.Listener.Listener Model Msg) -- How any replies to the message should be handled.
    }
