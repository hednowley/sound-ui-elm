module Audio exposing (StreamRequest, makeStreamRequest)

import Model exposing (Model)
import String exposing (fromInt)


type alias StreamRequest =
    { url : String, token : String }


makeStreamRequest : Model -> Int -> String -> StreamRequest
makeStreamRequest model songId token =
    { url = model.config.root ++ "/api/stream?id=" ++ fromInt songId, token = token }
