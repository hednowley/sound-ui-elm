module Audio.Select exposing (..)

import Array
import AudioState exposing (State(..))
import Dict
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Routing exposing (Route(..))


getSongState : Int -> Model -> Maybe State
getSongState songId model =
    Dict.get songId model.songCache


getItemState : Int -> Model -> Maybe State
getItemState index model =
    getSongId model index
        |> Maybe.andThen (\s -> getSongState s model)


getSongId : Model -> Int -> Maybe Int
getSongId model index =
    Array.get index model.playlist


getCurrentSongId : Model -> Maybe Int
getCurrentSongId model =
    model.playing
        |> Maybe.andThen (getSongId model)


getCurrentSongState : Model -> Maybe State
getCurrentSongState model =
    getCurrentSongId model |> Maybe.andThen (\s -> getSongState s model)
