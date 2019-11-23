module Socket.Types exposing (RequestData)

import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg)
import Socket.Listener


{-| Describes a message to send down the websocket and optionally how to handle a response to that message.
-}
type alias RequestData =
    { method : String
    , params : Maybe Json.Encode.Value
    , listener : Maybe (Socket.Listener.Listener Model Msg) -- How any replies to the message should be handled.
    }
