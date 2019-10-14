module Audio exposing (getAudioUrl)

import Model exposing (Model)
import String exposing (fromInt)


getAudioUrl : Model -> Int -> String
getAudioUrl model songId =
    model.config.root ++ "/api/stream?id=" ++ fromInt songId
