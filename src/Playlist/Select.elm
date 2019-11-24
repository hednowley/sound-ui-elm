module Playlist.Select exposing (getPlaylist, getPlaylistSongs)

import Dict
import Entities.Playlist exposing (Playlist)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)


getPlaylist : Int -> Model -> Loadable Playlist
getPlaylist id model =
    Dict.get id model.loadedPlaylists |> Maybe.withDefault Absent


getPlaylistSongs : Playlist -> List SongSummary
getPlaylistSongs playlist =
    playlist.songs
