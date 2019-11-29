module Playlist.Select exposing (getPlaylist, getPlaylistSongs)

import Dict
import Entities.Playlist exposing (Playlist)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Playlist.Types exposing (PlaylistId, getRawPlaylistId)

getPlaylist : PlaylistId -> Model -> Loadable Playlist
getPlaylist id model =
    Dict.get (getRawPlaylistId id) model.loadedPlaylists |> Maybe.withDefault Absent


getPlaylistSongs : Playlist -> List SongSummary
getPlaylistSongs playlist =
    playlist.songs
