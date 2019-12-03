module Album.Select exposing (getAlbum, getAlbumArt, getAlbumSongs)

import Album.Types exposing (AlbumId, getRawAlbumId)
import Dict
import Entities.Album exposing (Album)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)


getAlbum : AlbumId -> Model -> Loadable Album
getAlbum albumId model =
    Dict.get (getRawAlbumId albumId) model.loadedAlbums |> Maybe.withDefault Absent


getAlbumSongs : Album -> List SongSummary
getAlbumSongs album =
    List.sortBy .track album.songs


getAlbumArt : Maybe String -> String
getAlbumArt art =
    case art of
        Nothing ->
            ""

        Just id ->
            "/api/art?size=120&id=" ++ id
