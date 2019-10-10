module Ws.Message exposing (Message(..), parse)

import Json.Decode exposing (Decoder, Value, andThen, decodeString, errorToString, fail, field, map, oneOf, string)
import Ws.Notification as N exposing (Notification, decode)
import Ws.Response as R exposing (Response, decode)


{-| A message received through a websocket.
-}
type Message
    = Response Response
    | Notification Notification


{-| Try to parse a JSON string into a message.
-}
parse : String -> Result String Message
parse =
    decodeString decode >> Result.mapError errorToString


{-| Decode JSON into a message.
-}
decode : Decoder Message
decode =
    field "jsonrpc" string
        |> andThen decodeInner


decodeInner : String -> Decoder Message
decodeInner version =
    case version of
        "2.0" ->
            oneOf
                [ map Response R.decode
                , map Notification N.decode
                ]

        _ ->
            fail "Bad RPC version!"
