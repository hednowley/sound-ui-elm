module Playlist.Fetch exposing (fetchPlaylist)

import Dict
import Entities.Playlist exposing (Playlist)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Nexus.Fetch exposing (fetch)
import Playlist.Select
import Playlist.Types exposing (PlaylistId, getRawPlaylistId)
import Socket.Actions exposing (addListenerExternal)
import Socket.Core exposing (sendMessageWithId)
import Socket.DTO.Playlist exposing (convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.MessageId exposing (MessageId)
import Socket.RequestData exposing (RequestData)
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
        .loadedPlaylists
        (\repo -> \m -> { m | loadedPlaylists = repo })
        saveSongs
        maybeCallback


saveSongs : Playlist -> Model -> Model
saveSongs playlist model =
    { model
        | songs =
            insertMany
                (.id >> getRawSongId)
                identity
                playlist.songs
                model.songs
    }
