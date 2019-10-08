module Ws.Methods.StartScan exposing (prepareRequest)

import Json.Encode
import Ws.Types exposing (RequestData)


prepareRequest : Bool -> Bool -> RequestData
prepareRequest shouldUpdate shouldDelete =
    { method = "startScan"
    , params = makeRequest shouldUpdate shouldDelete |> Just
    , listener = Nothing
    }


makeRequest : Bool -> Bool -> Json.Encode.Value
makeRequest shouldUpdate shouldDelete =
    Json.Encode.object
        [ ( "update", Json.Encode.bool shouldUpdate )
        , ( "delete", Json.Encode.bool shouldDelete )
        ]
