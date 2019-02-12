module JSON.Scan exposing (Response, responseDecoder)

import Json.Decode exposing (Decoder, bool, field, int, map2)

type alias Response =
    { isScanning : Bool
    , count : Int
    }


statusDecoder : Decoder Response
statusDecoder =
    map2 Response
        (field "scanning" bool)
        (field "count" int)


responseDecoder : Decoder Response
responseDecoder =
    field "subsonic-response" (field "scanStatus" statusDecoder)
