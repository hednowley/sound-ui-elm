module DTO.Authenticate exposing (Response, responseDecoder)

import Json.Decode exposing (Decoder, field, map2, string)

type alias Response =
    { status : String, token : String }


responseDecoder : Decoder Response
responseDecoder =
    map2 Response
        (field "status" string)
        (field "data" (field "token" string))