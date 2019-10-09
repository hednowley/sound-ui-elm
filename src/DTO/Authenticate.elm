module DTO.Authenticate exposing (Response, responseDecoder)

import Json.Decode exposing (Decoder, andThen, fail, field, map, oneOf, string)


{-| Either an error message or a token.
-}
type alias Response =
    Result String String

{-| Decode the message.
-}
responseDecoder : Decoder Response
responseDecoder =
    field "status" string
        |> andThen dataDecoder


{-| Decode the data portion of the message.
-}
dataDecoder : String -> Decoder Response
dataDecoder status =
    case status of
        "success" ->
            map Ok (field "data" (field "token" string))

        "error" ->
            map Err (field "data" string)

        _ ->
            fail "Unknown status"
