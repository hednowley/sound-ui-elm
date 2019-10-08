module Entities.Artist exposing (Artist, Artists)

import Dict exposing (Dict)


type alias Artist =
    { id : Int
    , name : String
    }


type alias Artists =
    Dict Int Artist
