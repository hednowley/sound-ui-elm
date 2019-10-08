module Ws.Request exposing (makeRequest)

import Json.Encode exposing (Value, int, object, string)


makeRequest : Int -> String -> Maybe Value -> Value
makeRequest id method params =
    object
        [ ( "jsonrpc", string "2.0" )
        , ( "method", string method )
        , ( "params", maybeEncode params )
        , ( "id", int id )
        ]


maybeEncode : Maybe Value -> Value
maybeEncode maybe =
    case maybe of
        Just value ->
            value

        Nothing ->
            Json.Encode.object []
