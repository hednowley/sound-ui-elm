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
import Socket.Core as Socket
import Socket.MessageId exposing (MessageId(..))
import Socket.Methods.GetArtist exposing (getArtist)
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
            Socket.sendMessage
                (getArtist id)
                False
                { m | artist = Loadable.Loading <| MessageId 1337 }

        Just (Album id) ->
            loadAlbum id Nothing m

        Just (Playlist id) ->
            fetchPlaylist id Nothing m
