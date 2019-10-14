module Updaters exposing (cacheSong, logOut, onUrlChange, playSong)

import Audio exposing (makeLoadRequest)
import AudioState exposing (State(..))
import Dict
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
    case Dict.get songId model.songCache of
        Just AudioState.Loading ->
            ( { model | playing = Just songId }, Cmd.none )

        Just AudioState.Loaded ->
            ( { model | playing = Just songId }, Ports.playAudio songId )

        Nothing ->
            ( { model | playing = Just songId }, Ports.loadAudio <| makeLoadRequest model songId )


cacheSong : Int -> Model -> Model
cacheSong songId model =
    { model | songCache = Dict.insert songId AudioState.Loaded model.songCache }


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
