module Album.Select exposing (..)

import Dict
import Entities.Album exposing (Album)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)


getAlbum : Int -> Model -> Loadable Album
getAlbum id model =
    Dict.get id model.albums |> Maybe.withDefault Absent


getAlbumSongs : Album -> Model -> List SongSummary
getAlbumSongs album model =
    List.sortBy .track album.songs
