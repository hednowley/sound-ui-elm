module Ws.Methods.StartScan exposing (prepareRequest)

import Json.Encode
import Ws.Types exposing (RequestData)


prepareRequest : Bool -> RequestData
prepareRequest shouldUpdate =
    { method = "startScan"
    , params = makeRequest shouldUpdate
    , listener = Nothing
    }


makeRequest : Bool -> Json.Encode.Value
makeRequest shouldUpdate =
    Json.Encode.object
        [ ( "update", Json.Encode.bool shouldUpdate ) ]
