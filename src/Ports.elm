port module Ports exposing
    ( canPlayAudio
    , loadAudio
    , pauseAudio
    , playAudio
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



-- Outgoing ports


port setCache : Cache -> Cmd msg


port loadAudio : String -> Cmd msg


port playAudio : () -> Cmd msg


port pauseAudio : () -> Cmd msg


port websocketOut : Json.Encode.Value -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketClose : () -> Cmd msg



-- Incoming ports


port canPlayAudio : (() -> msg) -> Sub msg


port websocketOpened : (() -> msg) -> Sub msg


port websocketClosed : (() -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg
