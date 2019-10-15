module Updaters exposing (cacheSong, logOut, onUrlChange, playSong, queueSong)

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


playSong : Int -> Update Model Msg
playSong songId model =
    let
        m =
            queueSong songId { model | playing = Just songId }
    in
    case Dict.get songId m.songCache of
        Just AudioState.Loading ->
            ( m, Cmd.none )

        Just AudioState.Loaded ->
            ( m, Ports.playAudio songId )

        Nothing ->
            loadSong songId m


queueSong : Int -> Model -> Model
queueSong songId model =
    { model | playlist = model.playlist ++ [ songId ] }


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
