module Audio exposing (LoadRequest, makeLoadRequest)

import Model exposing (Model)
import String exposing (fromInt)


type alias LoadRequest =
    { url : String
    , songId : Int
    }


makeLoadRequest : Int -> LoadRequest
makeLoadRequest songId =
    { url = "/api/stream?id=" ++ fromInt songId
    , songId = songId
    }
