port module Ports exposing
    ( audioEnded
    , audioTime
    , canPlayAudio
    , loadAudio
    , pauseAudio
    , playAudio
    , setAudioTime
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


port loadAudio : Audio.LoadRequest -> Cmd msg


port playAudio : Int -> Cmd msg


port pauseAudio : () -> Cmd msg


port setAudioTime : Float -> Cmd msg


port websocketOut : Json.Encode.Value -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketClose : () -> Cmd msg



-- Incoming ports


port canPlayAudio : (Int -> msg) -> Sub msg


port audioEnded : (Int -> msg) -> Sub msg


port audioTime : (Float -> msg) -> Sub msg


port websocketOpened : (() -> msg) -> Sub msg


port websocketClosed : (() -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg
