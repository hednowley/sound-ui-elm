module Playlist.Update exposing (playPlaylist)

import Audio.AudioMsg exposing (AudioMsg(..))
import Entities.Playlist exposing (Playlist)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Player.Actions exposing (replacePlaylist)
import Playlist.Fetch exposing (fetchPlaylist)
import Playlist.Select exposing (getPlaylistSongs)
import Types exposing (Update)
import Playlist.Types exposing (PlaylistId)


playLoadedPlaylist : Playlist -> Update Model Msg
playLoadedPlaylist playlist =
    let
        songs =
            List.map .id (getPlaylistSongs playlist)
    in
    replacePlaylist songs


playPlaylist : PlaylistId -> Update Model Msg
playPlaylist playlistId =
    fetchPlaylist
        playlistId
        (Just playLoadedPlaylist)
