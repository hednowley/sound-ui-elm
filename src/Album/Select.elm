module Album.Select exposing (getAlbum, getAlbumArt, getAlbumSongs)

import Dict
import Entities.Album exposing (Album)
import Entities.AlbumSummary exposing (AlbumSummary)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)


getAlbum : Int -> Model -> Loadable Album
getAlbum id model =
    Dict.get id model.albums |> Maybe.withDefault Absent


getAlbumSongs : Album -> List SongSummary
getAlbumSongs album =
    List.sortBy .track album.songs


getAlbumArt : Model -> AlbumSummary -> String
getAlbumArt model album =
    case album.artId of
        Nothing ->
            ""

        Just id ->
            model.config.root ++ "/api/art?id=" ++ id
