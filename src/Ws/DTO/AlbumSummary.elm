module Ws.DTO.AlbumSummary exposing (AlbumSummary, convert, decode)

import Entities.AlbumSummary
import Json.Decode exposing (Decoder, field, int, map4, maybe, string)


type alias AlbumSummary =
    { id : Int
    , name : String
    , duration : Int
    , year : Maybe Int
    }


decode : Decoder AlbumSummary
decode =
    map4 AlbumSummary
        (field "id" int)
        (field "name" string)
        (field "duration" int)
        (maybe <| field "year" int)


convert : AlbumSummary -> Entities.AlbumSummary.AlbumSummary
convert album =
    { id = album.id
    , name = album.name
    , duration = album.duration
    , year = album.year
    }
