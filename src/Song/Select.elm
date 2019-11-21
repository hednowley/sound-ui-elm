module Song.Select exposing (getSong)

import Array
import AudioState exposing (State(..))
import Dict
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Routing exposing (Route(..))


getSong : Model -> Int -> Maybe SongSummary
getSong model songId =
    Dict.get songId model.songs
