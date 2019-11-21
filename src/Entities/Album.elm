module Entities.Album exposing (Album)

import Entities.SongSummary exposing (SongSummary)


type alias Album =
    { id : Int
    , artId : Maybe String
    , name : String
    , songs : List SongSummary
    }
