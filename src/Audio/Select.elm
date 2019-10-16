module Audio.Select exposing (..)

import Array exposing (push)
import Audio exposing (makeLoadRequest)
import AudioState exposing (State(..))
import Dict
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Routing exposing (Route(..))
import Types exposing (Update)
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Methods.GetAlbum exposing (getAlbum)
import Ws.Methods.GetArtist exposing (getArtist)


getSongState : Int -> Model -> Maybe State
getSongState songId model =
    Dict.get songId model.songCache


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
