module Playlist.Update exposing (playPlaylist)

import Audio.Update exposing (replacePlaylist)
import Dict
import Entities.Playlist exposing (Playlist)
import Loadable exposing (Loadable(..))
import Model exposing (Model, addListener)
import Msg exposing (AudioMsg(..), Msg(..))
import Playlist.Fetch exposing (fetchPlaylist)
import Playlist.Select exposing (getPlaylistSongs)
import Types exposing (Update, noOp)
import Ws.Core exposing (sendMessage)
import Ws.Methods.GetPlaylist exposing (getPlaylist)


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
