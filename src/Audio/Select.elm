module Audio.Select exposing (getCurrentSongId, getCurrentSongState, getSongId, getSongState)

import Array
import AudioState exposing (State(..))
import Dict
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Routing exposing (Route(..))
import Song.Types exposing (SongId(..), getRawSongId)


getSongState : SongId -> Model -> Maybe State
getSongState songId model =
    Dict.get (getRawSongId songId) model.songCache


getSongId : Model -> Int -> Maybe SongId
getSongId model index =
    Array.get index model.playlist


getCurrentSongId : Model -> Maybe SongId
getCurrentSongId model =
    model.playing
        |> Maybe.andThen (getSongId model)


getCurrentSongState : Model -> Maybe State
getCurrentSongState model =
    getCurrentSongId model |> Maybe.andThen (\s -> getSongState s model)
