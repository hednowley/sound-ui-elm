module Ws.DTO.SongSummary exposing (SongSummary, convert, decode)

import Entities.SongSummary
import Json.Decode exposing (Decoder, field, int, map2, maybe, string)


type alias SongSummary =
    { id : Int
    , name : String
    }


decode : Decoder SongSummary
decode =
    map2 SongSummary
        (field "id" int)
        (field "name" string)


convert : SongSummary -> Entities.SongSummary.SongSummary
convert song =
    { id = song.id
    , name = song.name
    }
