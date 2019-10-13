module Entities.Artist exposing (Artist)

import Entities.Album exposing (Album)


type alias Artist =
    { id : Int
    , name : String
    , albums : List Album
    }
