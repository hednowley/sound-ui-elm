
{-
module JSON.Response exposing (decodeError, decodeResponse)

import Json.Decode exposing (Decoder, bool, decodeString, fail, field, string)

statusDecoder : Decoder String
statusDecoder =
    field "status" string


decodeErrorMessage : String -> String
decodeErrorMessage response =
    case decodeString (field "message" string) response of
        Ok str ->
            str

        Err _ ->
            "Unknown error"

decodeError : String -> Maybe String
decodeError response =
    case decodeString statusDecoder response of
        Ok str ->
            case str of
                "error" ->
                    Just <| decodeErrorMessage response

                _ ->
                    Nothing

        Err _ ->
            Just "Unknown status"

decodeResponse : String -> Decoder a -> Decoder b -> Status a
decodeResponse response successDecoder failDecoder =
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



decodeData : String -> Decoder a -> a
decodeData response decoder =
    let
        dataDecoder =
            field "data" decoder
    in
    case decodeString dataDecoder response of
        Ok a ->
            a

        Err _ ->
            "Unknown error"




-}