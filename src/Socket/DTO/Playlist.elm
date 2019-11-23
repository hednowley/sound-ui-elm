module Socket.DTO.Playlist exposing (Playlist, convert, decode)

import Entities.Playlist
import Json.Decode exposing (Decoder, field, int, list, map3, maybe, string)
import Socket.DTO.SongSummary exposing (SongSummary)


type alias Playlist =
    { id : Int
    , name : String
    , songs : List SongSummary
    }


decode : Decoder Playlist
decode =
    map3 Playlist
        (field "id" int)
        (field "name" string)
        (field "songs" <| list Socket.DTO.SongSummary.decode)


convert : Playlist -> Entities.Playlist.Playlist
convert playlist =
    { id = playlist.id
    , name = playlist.name
    , songs = List.map Socket.DTO.SongSummary.convert playlist.songs
    }
