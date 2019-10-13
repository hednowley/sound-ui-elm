module Entities.Artist exposing (Artist)

import Entities.AlbumSummary exposing (AlbumSummary)


type alias Artist =
    { id : Int
    , name : String
    , albums : List AlbumSummary
    }
