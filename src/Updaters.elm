module Updaters exposing
    ( logOut
    , onUrlChange
    )

import Album.Fetch exposing (fetchAlbum)
import Artist.Fetch exposing (fetchArtist)
import Artist.Types exposing (ArtistId(..))
import Audio.Select exposing (..)
import AudioState exposing (State(..))
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Playlist.Fetch exposing (fetchPlaylist)
import Ports
import Routing exposing (Route(..))
import Socket.MessageId exposing (MessageId(..))
import Types exposing (Update)
import Url exposing (Url)


logOut : Update Model Msg
logOut model =
    ( { model | username = "", token = Absent }, Ports.websocketClose () )


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
            fetchArtist Nothing id m

        Just (Album id) ->
            fetchAlbum Nothing id m

        Just (Playlist id) ->
            fetchPlaylist Nothing id m
