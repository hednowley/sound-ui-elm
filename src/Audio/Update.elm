module Audio.Update exposing (..)

import Array exposing (fromList, push)
import Audio exposing (makeLoadRequest)
import Audio.Select exposing (..)
import AudioState exposing (State(..))
import Dict
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Routing exposing (Route(..))
import Types exposing (Update, combine)


updateSongState : Int -> AudioState.State -> Model -> Model
updateSongState songId state model =
    { model | songCache = Dict.insert songId state model.songCache }


goNext : Update Model Msg
goNext model =
    case model.playing of
        Just index ->
            if Array.length model.playlist - 1 == index then
                -- No next song
                ( model, Cmd.none )

            else
                case getCurrentSongState model of
                    Just (Playing _) ->
                        playItem (index + 1) model

                    _ ->
                        case getCurrentSongId model of
                            Just songId ->
                                loadSong songId model

                            Nothing ->
                                ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


pauseCurrent : Update Model Msg
pauseCurrent model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.pauseAudio songId )

        Nothing ->
            ( model, Cmd.none )


setCurrentTime : Float -> Update Model Msg
setCurrentTime time model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.setAudioTime { songId = songId, time = time } )

        Nothing ->
            ( model, Cmd.none )


resumeCurrent : Update Model Msg
resumeCurrent model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.resumeAudio songId )

        Nothing ->
            ( model, Cmd.none )


onSongLoaded : Int -> Update Model Msg
onSongLoaded songId model =
    let
        m =
            updateSongState songId AudioState.Loaded model

        playing =
            Maybe.andThen (getSongId model) model.playing
    in
    if playing == Just songId then
        playSong songId m

    else
        ( m, Cmd.none )


onTimeChanged : Int -> Float -> Model -> Model
onTimeChanged songId time model =
    case getSongState songId model of
        Just (Playing _) ->
            updateSongState songId (Playing time) model

        Just (Paused _) ->
            updateSongState songId (Paused time) model

        _ ->
            model


playSong : Int -> Update Model Msg
playSong songId model =
    case Dict.get songId model.songCache of
        Just AudioState.Loading ->
            ( model, Cmd.none )

        Just AudioState.Loaded ->
            ( model, Ports.playAudio songId )

        Just (AudioState.Paused _) ->
            ( model, Ports.playAudio songId )

        Just (AudioState.Playing _) ->
            ( model, Ports.playAudio songId )

        _ ->
            loadSong songId model


onSongEnded : Int -> Update Model Msg
onSongEnded songId model =
    case model.playing of
        Just index ->
            if Array.length model.playlist - 1 == index then
                -- The last song has finished
                ( { model | playing = Nothing }, Cmd.none )

            else
                playItem (index + 1) model

        Nothing ->
            ( model, Cmd.none )


playItem : Int -> Update Model Msg
playItem index model =
    case getSongId model index of
        Just songId ->
            model
                |> combine
                    pauseCurrent
                    (\m -> playSong songId { m | playing = Just index })

        Nothing ->
            ( model, Cmd.none )


replacePlaylistWithoutPausing : List Int -> Update Model Msg
replacePlaylistWithoutPausing playlist model =
    let
        m =
            { model | playlist = fromList playlist }
    in
    case playlist of
        [] ->
            ( m, Cmd.none )

        first :: _ ->
            playSong first { m | playing = Just 0 }


replacePlaylist : List Int -> Update Model Msg
replacePlaylist playlist =
    combine
        pauseCurrent
        (replacePlaylistWithoutPausing playlist)


queueAndPlaySong : Int -> Update Model Msg
queueAndPlaySong songId model =
    let
        m =
            queueSong songId model
    in
    playItem (Array.length m.playlist - 1) m


queueSong : Int -> Model -> Model
queueSong songId model =
    { model | playlist = push songId model.playlist }


loadSong : Int -> Update Model Msg
loadSong songId model =
    let
        m =
            updateSongState songId AudioState.Loading model
    in
    ( m, Ports.loadAudio <| makeLoadRequest m songId )


saveSong : SongSummary -> Model -> Model
saveSong song model =
    { model | songs = Dict.insert song.id song model.songs }
