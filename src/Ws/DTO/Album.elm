module Ws.DTO.Album exposing (Album, convert, decode)

import Entities.Album
import Json.Decode exposing (Decoder, field, int, list, map3, map4, maybe, string)


type alias Album =
    { id : Int
    , name : String
    , duration : Int
    , year : Maybe Int
    }


decode : Decoder Album
decode =
    map4 Album
        (field "id" int)
        (field "name" string)
        (field "duration" int)
        (maybe <| field "year" int)


convert : Album -> Entities.Album.Album
convert album =
    { id = album.id
    , name = album.name
    , duration = album.duration
    , year = album.year
    }
