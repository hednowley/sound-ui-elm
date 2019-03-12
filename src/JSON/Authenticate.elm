module JSON.Authenticate exposing (Response, responseDecoder)

import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode

type alias Response =
    { status : String, token : String }


responseDecoder : Decoder Response
responseDecoder =
    map2 Response
        (field "status" string)
        (field "data" (field "token" string))