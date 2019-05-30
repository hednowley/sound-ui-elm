port module Ports exposing (setStorage, websocketClose, websocketIn, websocketOpen, websocketOpened, websocketOut)

import Json.Encode
import Model exposing (PackedModel)


port setStorage : PackedModel -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketClose : () -> Cmd msg


port websocketOpened : (Bool -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Json.Encode.Value -> Cmd msg
