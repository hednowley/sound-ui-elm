module Updaters exposing
    ( logOut
    , onUrlChange
    )

import Album.Update exposing (loadAlbum)
import Artist.Types exposing (ArtistId(..))
import Audio.Select exposing (..)
import AudioState exposing (State(..))
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Playlist.Fetch exposing (fetchPlaylist)
import Ports
import Routing exposing (Route(..))
import Types exposing (Update)
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Methods.GetArtist exposing (getArtist)
import Ws.Methods.GetPlaylist exposing (getPlaylist)


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
            Ws.sendMessage
                (getArtist id)
                { m | artist = Loadable.Loading 1337 }

        Just (Album id) ->
            loadAlbum id Nothing m

        Just (Playlist id) ->
            fetchPlaylist id Nothing m
