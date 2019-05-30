module Ws.Notification exposing (Notification, decode)

import Json.Decode exposing (Decoder, decodeString, field, int, map3, maybe, string, value)


type alias Notification =
    { method : String
    , params : Maybe Json.Decode.Value
    }


type alias RawNotification =
    { method : String
    , params : Maybe Json.Decode.Value
    , jsonrpc : String
    }


decoder : Decoder RawNotification
decoder =
    map3 RawNotification
        (field "method" string)
        (maybe (field "params" value))
        (field "jsonrpc" string)


decode : String -> Maybe Notification
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


convert : RawNotification -> Maybe Notification
convert raw =
    case raw.jsonrpc of
        "2.0" ->
            Just <| Notification raw.method raw.params

        rest ->
            Nothing
