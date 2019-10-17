module Album.Select exposing (..)

import Entities.Album exposing (Album)
import Entities.SongSummary exposing (SongSummary)
import Model exposing (Model)


getAlbumSongs : Album -> Model -> List SongSummary
getAlbumSongs album model =
    List.sortBy .track album.songs
