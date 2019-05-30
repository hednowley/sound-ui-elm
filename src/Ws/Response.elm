module Ws.Response exposing (Response, decode)

import Json.Decode exposing (Decoder, decodeString, field, int, map3, maybe, string, value)


type alias Response =
    { id : Int
    , body : Result Json.Decode.Value Json.Decode.Value -- Either the error or success body of the response
    }


type alias RawResponse =
    { id : Int
    , result : Maybe Json.Decode.Value
    , error : Maybe Json.Decode.Value
    }


decoder : Decoder RawResponse
decoder =
    map3 RawResponse
        (field "id" int)
        (maybe (field "result" value))
        (maybe (field "error" value))


decode : String -> Maybe Response
decode raw =
    let
        result =
            Json.Decode.decodeString decoder raw
    in
    case result of
        Ok decoded ->
            convert decoded

        Err error ->
            Nothing


convert : RawResponse -> Maybe Response
convert raw =
    case raw.error of
        Just error ->
            Just <| Response raw.id <| Result.Err error

        Nothing ->
            case raw.result of
                Just result ->
                    Just <| Response raw.id <| Result.Ok result

                Nothing ->
                    Nothing
