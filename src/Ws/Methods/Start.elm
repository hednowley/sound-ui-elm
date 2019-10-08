module Ws.Methods.Start exposing (start)

import Json.Decode
import Json.Encode
import Model exposing (Model)
import Ws.Listener exposing (Listener)
import Ws.Types exposing (RequestData)


{-| This should be run once the websocket handshake is complete.
-}
start : Model -> Model
start model =
    { model | message = "Started" }
