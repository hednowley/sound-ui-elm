module Ws.DTO.SongSummary exposing (SongSummary, convert, decode)

import Entities.SongSummary
import Json.Decode exposing (Decoder, field, int, map3, string)
import Song.Types exposing (SongId(..))


type alias SongSummary =
    { id : Int
    , name : String
    , track : Int
    }


decode : Decoder SongSummary
decode =
    map3 SongSummary
        (field "id" int)
        (field "name" string)
        (field "track" int)


convert : SongSummary -> Entities.SongSummary.SongSummary
convert song =
    { id = SongId song.id
    , name = song.name
    , track = song.track
    }
