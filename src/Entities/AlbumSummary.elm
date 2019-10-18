module Entities.AlbumSummary exposing (AlbumSummary)


type alias AlbumSummary =
    { id : Int
    , name : String
    , duration : Int
    , year : Maybe Int
    , artId : Maybe String
    }
