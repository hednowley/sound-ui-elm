module Playlist.Fetch exposing (fetchPlaylist)

import Entities.Playlist exposing (Playlist)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Nexus.Fetch exposing (fetch)
import Playlist.Types exposing (PlaylistId, getRawPlaylistId)
import Socket.DTO.Playlist exposing (convert, decode)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


fetchPlaylist : Maybe (Playlist -> Update Model Msg) -> PlaylistId -> Update Model Msg
fetchPlaylist maybeCallback =
    fetch
        getRawPlaylistId
        "getPlaylist"
        decode
        convert
        { get = .playlists
        , set = \repo -> \m -> { m | playlists = repo }
        }
        saveSongs
        maybeCallback


saveSongs : Playlist -> Update Model Msg
saveSongs playlist model =
    ( { model
        | songs =
            insertMany
                (.id >> getRawSongId)
                identity
                playlist.songs
                model.songs
      }
    , Cmd.none
    )
