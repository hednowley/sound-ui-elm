module Audio.Actions exposing
    ( loadSong
    , onSongLoaded
    , onTimeChanged
    , playSong
    , updateSongState
    )

import Array exposing (Array, append, fromList, length, push, slice)
import Audio exposing (makeLoadRequest)
import Audio.AudioMsg
import Audio.Select exposing (getSongState)
import AudioState exposing (State(..))
import Dict
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Player.Select exposing (getCurrentSongId, getCurrentSongState, getSongId)
import Ports
import Random
import Random.Array exposing (shuffle)
import Routing exposing (Route(..))
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update, combine)


updateSongState : SongId -> AudioState.State -> Model -> Model
updateSongState songId state model =
    let
        (SongId s) =
            songId
    in
    { model | songCache = Dict.insert s state model.songCache }


onSongLoaded : SongId -> Update Model Msg
onSongLoaded songId model =
    let
        m =
            updateSongState
                songId
                (AudioState.Loaded { duration = Nothing })
                model

        playing =
            Maybe.andThen (getSongId model) model.player.playing
    in
    if playing == Just songId then
        playSong songId m

    else
        ( m, Cmd.none )


onTimeChanged : SongId -> Float -> Model -> Model
onTimeChanged songId time model =
    case getSongState songId model of
        Just (Playing p) ->
            updateSongState songId (Playing { p | time = time }) model

        _ ->
            model


playSong : SongId -> Update Model Msg
playSong songId model =
    case getSongState songId model of
        Just AudioState.Loading ->
            ( model, Cmd.none )

        Just (AudioState.Loaded _) ->
            ( model, Ports.playAudio (getRawSongId songId) )

        Just (AudioState.Playing _) ->
            ( model, Ports.playAudio (getRawSongId songId) )

        _ ->
            loadSong songId model


loadSong : SongId -> Update Model Msg
loadSong songId model =
    let
        m =
            updateSongState songId AudioState.Loading model
    in
    ( m, Ports.loadAudio <| makeLoadRequest songId )
