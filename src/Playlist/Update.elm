module Playlist.Update exposing (playPlaylist)

import Audio.Actions exposing (replacePlaylist)
import Audio.AudioMsg exposing (AudioMsg(..))
import Dict
import Entities.Playlist exposing (Playlist)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Playlist.Fetch exposing (fetchPlaylist)
import Playlist.Select exposing (getPlaylistSongs)
import Socket.Actions exposing (addListener)
import Socket.Core exposing (sendMessage)
import Socket.Methods.GetPlaylist exposing (getPlaylist)
import Types exposing (Update, noOp)


playLoadedPlaylist : Playlist -> Update Model Msg
playLoadedPlaylist playlist =
    let
        songs =
            List.map .id (getPlaylistSongs playlist)
    in
    replacePlaylist songs


playPlaylist : Int -> Update Model Msg
playPlaylist playlistId =
    fetchPlaylist
        playlistId
        (Just playLoadedPlaylist)
