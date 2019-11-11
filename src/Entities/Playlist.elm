module Entities.Playlist exposing (Playlist)

import Entities.SongSummary exposing (SongSummary)


type alias Playlist =
    { id : Int
    , name : String
    , songs : List SongSummary
    }
