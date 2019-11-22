module Entities.AlbumSummary exposing (AlbumSummary)

import Album.Types exposing (AlbumId)


type alias AlbumSummary =
    { id : AlbumId
    , name : String
    , duration : Int
    , year : Maybe Int
    , artId : Maybe String
    }
