module Ws.Types exposing (RequestData)

import Json.Encode
import Model exposing (Model)
import Ws.Listener


type alias RequestData =
    { method : String
    , params : Json.Encode.Value
    , listener : Maybe (Ws.Listener.Listener Model)
    }
