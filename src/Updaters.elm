module Updaters exposing
    ( logOut
    , onSongLoaded
    , onUrlChange
    , playItem
    , queueAndPlaySong
    , queueSong
    )

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


logOut : Update Model Msg
logOut model =
    ( { model | username = "", token = Absent }, Ports.websocketClose () )


onSongLoaded : Int -> Update Model Msg
onSongLoaded songId model =
    let
        m =
            cacheSong songId AudioState.Loaded model

        playing =
            Maybe.andThen (Audio.getSongId model) model.playing
    in
    if playing == Just songId then
        playSong songId m

    else
        ( m, Cmd.none )


playItem : Int -> Update Model Msg
playItem index model =
    case Audio.getSongId model index of
        Just songId ->
            playSong songId { model | playing = Just index }

        Nothing ->
            ( model, Cmd.none )


queueAndPlaySong : Int -> Update Model Msg
queueAndPlaySong songId model =
    let
        m =
            queueSong songId model
    in
    playItem (Array.length m.playlist - 1) m


playSong : Int -> Update Model Msg
playSong songId model =
    case Dict.get songId model.songCache of
        Just AudioState.Loading ->
            ( model, Cmd.none )

        Just AudioState.Loaded ->
            ( model, Ports.playAudio songId )

        Nothing ->
            loadSong songId model


queueSong : Int -> Model -> Model
queueSong songId model =
    { model | playlist = push songId model.playlist }


loadSong : Int -> Update Model Msg
loadSong songId model =
    let
        m =
            cacheSong songId AudioState.Loading model
    in
    ( m, Ports.loadAudio <| makeLoadRequest m songId )


cacheSong : Int -> AudioState.State -> Model -> Model
cacheSong songId state model =
    { model | songCache = Dict.insert songId state model.songCache }


saveSong : SongSummary -> Model -> Model
saveSong song model =
    { model | songs = Dict.insert song.id song model.songs }


onUrlChange : Url -> Update Model Msg
onUrlChange url model =
    let
        m =
            { model | route = Routing.parseUrl url }
    in
    case m.route of
        Nothing ->
            ( m, Cmd.none )

        Just (Artist id) ->
            Ws.sendMessage
                (getArtist id)
                { m | artist = Loadable.Loading }

        Just (Album id) ->
            Ws.sendMessage
                (getAlbum id)
                { m | album = Loadable.Loading }
