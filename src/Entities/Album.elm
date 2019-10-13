module Entities.Album exposing (Album)

import Entities.SongSummary exposing (SongSummary)


type alias Album =
    { id : Int
    , name : String
    , songs : List SongSummary
    }
