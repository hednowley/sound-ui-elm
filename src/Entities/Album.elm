module Entities.Album exposing (Album)


type alias Album =
    { id : Int
    , name : String
    , duration : Int
    , year : Maybe Int
    }
