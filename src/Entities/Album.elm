module Entities.Album exposing (Album)

import Entities.SongSummary exposing (SongSummary)
import Song.Types exposing (SongId)


type alias Album =
    { id : Int
    , artId : Maybe String
    , name : String
    , songs : List SongId
    }
