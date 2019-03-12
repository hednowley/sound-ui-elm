module DTO.Ticket exposing (responseDecoder)

import Json.Decode exposing (Decoder, field, string)


responseDecoder : Decoder String
responseDecoder =
    field "data" (field "ticket" string)
