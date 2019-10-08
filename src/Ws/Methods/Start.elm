module Ws.Methods.Start exposing (start)

import Json.Decode
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.Core as Ws
import Ws.Types exposing (RequestData)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start model =
    Ws.sendMessage model sayHello


sayHello : RequestData
sayHello =
    { method = "hello"
    , params = Nothing
    , listener = Nothing
    }
