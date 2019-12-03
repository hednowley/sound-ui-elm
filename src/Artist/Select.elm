module Artist.Select exposing (getArtist)

import Artist.Types exposing (ArtistId, getRawArtistId)
import Dict
import Entities.Artist exposing (Artist)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Model exposing (Model)


getArtist : ArtistId -> Model -> Loadable Artist
getArtist id model =
    Dict.get (getRawArtistId id) model.loadedArtists |> Maybe.withDefault Absent
