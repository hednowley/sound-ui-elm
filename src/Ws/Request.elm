module Ws.Request exposing (makeRequest)

import Json.Encode


makeRequest : Int -> String -> Json.Encode.Value -> Json.Encode.Value
makeRequest id method params =
    Json.Encode.object
        [ ( "jsonrpc", Json.Encode.string "2.0" )
        , ( "method", Json.Encode.string method )
        , ( "params", params )
        , ( "id", Json.Encode.int id )
        ]
