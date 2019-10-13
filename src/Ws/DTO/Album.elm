module Ws.DTO.Album exposing (Album, convert, decode)

import Entities.Album
import Json.Decode exposing (Decoder, field, int, list, map5, maybe, string)
import Ws.DTO.SongSummary exposing (SongSummary)


type alias Album =
    { id : Int
    , name : String
    , duration : Int
    , year : Maybe Int
    , songs : List SongSummary
    }


decode : Decoder Album
decode =
    map5 Album
        (field "id" int)
        (field "name" string)
        (field "duration" int)
        (maybe <| field "year" int)
        (field "songs" <| list Ws.DTO.SongSummary.decode)


convert : Album -> Entities.Album.Album
convert album =
    { id = album.id
    , name = album.name
    , songs = List.map Ws.DTO.SongSummary.convert album.songs
    }
