module Websocket.Response exposing (Response, responseDecoder)

import Json.Decode exposing (Decoder, bool, decodeString, fail, int, maybe, field, string, map3)

type alias Response = 
    {
        id : Int
        , result : Maybe String
        , error : Maybe String
    }

responseDecoder : Decoder Response
responseDecoder = 
    map3 Response
        ( field "id" int)
        ( field "result" (maybe string))
        ( field "error" (maybe string))