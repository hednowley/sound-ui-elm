module Ws.DTO.Artist exposing (Artist, convert, decode)

import Entities.Artist
import Json.Decode exposing (Decoder, field, int, list, map3, string)
import Ws.DTO.AlbumSummary exposing (AlbumSummary)


type alias Artist =
    { id : Int
    , name : String
    , albums : List AlbumSummary
    }


decode : Decoder Artist
decode =
    map3 Artist
        (field "id" int)
        (field "name" string)
        (field "albums"
            (list Ws.DTO.AlbumSummary.decode)
        )


convert : Artist -> Entities.Artist.Artist
convert artist =
    { id = artist.id
    , name = artist.name
    , albums = List.map Ws.DTO.AlbumSummary.convert artist.albums
    }
