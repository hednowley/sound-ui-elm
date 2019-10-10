port module Ports exposing (setCache, websocketClose, websocketIn, websocketOpen, websocketOpened, websocketOut)

import Cache exposing (Cache)
import Json.Encode


port setCache : Cache -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketClose : () -> Cmd msg


port websocketOpened : (() -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Json.Encode.Value -> Cmd msg
