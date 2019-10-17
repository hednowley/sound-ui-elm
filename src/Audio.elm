module Audio exposing (LoadRequest, State, makeLoadRequest)

import Model exposing (Model)
import String exposing (fromInt)


type alias LoadRequest =
    { url : String
    , songId : Int
    }


type State
    = Loading
    | Loaded


makeLoadRequest : Model -> Int -> LoadRequest
makeLoadRequest model songId =
    { url = model.config.root ++ "/api/stream?id=" ++ fromInt songId
    , songId = songId
    }
