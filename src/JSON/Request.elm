module JSON.Request exposing (makeRequest, makeHandshakeRequest, makeStartScanRequest)

import Json.Encode


makeRequest : Int -> String -> Json.Encode.Value -> Json.Encode.Value
makeRequest id method params =
    Json.Encode.object
        [ ( "jsonrpc", Json.Encode.string "2.0" )
        , ( "method", Json.Encode.string method )
        , ( "params", params )
        , ( "id", Json.Encode.int id )
        ]


makeHandshakeRequest : String -> Json.Encode.Value
makeHandshakeRequest ticket =
    Json.Encode.object
        [ ( "ticket", Json.Encode.string ticket ) ]

makeStartScanRequest : Bool -> Json.Encode.Value
makeStartScanRequest update =
    Json.Encode.object
        [ ( "update", Json.Encode.bool update ) ]
