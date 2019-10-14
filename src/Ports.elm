port module Ports exposing
    ( loadAudio
    , setCache
    , websocketClose
    , websocketClosed
    , websocketIn
    , websocketOpen
    , websocketOpened
    , websocketOut
    )

import Audio
import Cache exposing (Cache)
import Json.Encode


port setCache : Cache -> Cmd msg


port loadAudio : String -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketClose : () -> Cmd msg


port websocketOpened : (() -> msg) -> Sub msg


port websocketClosed : (() -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Json.Encode.Value -> Cmd msg
