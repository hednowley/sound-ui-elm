module JSON.Handshake exposing (responseDecoder)

import Json.Decode exposing (Decoder, field, bool)


responseDecoder : Decoder Bool
responseDecoder =
    field "data" (field "accepted" bool)
