module JSON.Response exposing (responseDecoder)

import Json.Decode exposing (Decoder, bool, decodeString, field, string)


type Status a
    = Success a
    | Fail a
    | Error String


statusDecoder : Decoder String
statusDecoder =
    field "status" string

decodeError : String -> String
decodeError response =
    case decodeString (field "message" string) response of 
        Ok str -> str
        Err _ -> "Unknown error"

decodeData : String -> Decoder a -> a
decodeData response decoder =
    let
        dataDecoder = field "data" decoder
    in
    case decodeString dataDecoder response of 
        Ok a -> a
        Err _ -> "Unknown error"

responseDecoder : String -> Decoder a -> Status a
responseDecoder response decoder =

    case decodeString statusDecoder response of
        Ok str ->
            case str of
                "success" ->
                    Success (decodeString decoder response)

                "fail" ->
                    Fail (decodeString decoder response)

                "error" ->
                    Error (decodeError response)

                _ ->
                    Error "Unknown status"

        Err _ ->
            Error "Unknown status"
