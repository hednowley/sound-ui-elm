module Ws.Methods.StartScan exposing (makeRequest)

import Json.Encode

makeRequest : Bool -> Json.Encode.Value
makeRequest update =
    Json.Encode.object
        [ ( "update", Json.Encode.bool update ) ]
