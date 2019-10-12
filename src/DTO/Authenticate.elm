module DTO.Authenticate exposing (Response, decode)

import Json.Decode exposing (Decoder, andThen, fail, field, map, string)


{-| Either an error message or a token.
-}
type alias Response =
    Result String String


{-| Decode the message.
-}
decode : Decoder Response
decode =
    field "status" string
        |> andThen decodeData


{-| Decode the data portion of the message.
-}
decodeData : String -> Decoder Response
decodeData status =
    case status of
        "success" ->
            map Ok (field "data" (field "token" string))

        "error" ->
            map Err (field "data" string)

        _ ->
            fail "Unknown status"
