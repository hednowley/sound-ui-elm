module Ws.Types exposing (RequestData)

import Json.Encode
import Model exposing (Model)
import Ws.Listener


{-| Describes a message to send down the websocket and optionally how to handle a response to that message.
-}
type alias RequestData =
    { method : String
    , params : Json.Encode.Value
    , listener : Maybe (Ws.Listener.Listener Model)
    }
