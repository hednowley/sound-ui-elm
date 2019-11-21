module Ws.DTO.Album exposing (Album, convert, decode)

import Entities.Album
import Json.Decode exposing (Decoder, field, int, list, map6, maybe, string)
import Ws.DTO.SongSummary exposing (SongSummary)


type alias Album =
    { id : Int
    , artId : Maybe String
    , name : String
    , duration : Int
    , year : Maybe Int
    , songs : List SongSummary
    }


decode : Decoder Album
decode =
    map6 Album
        (field "id" int)
        (maybe <| field "coverArt" string)
        (field "name" string)
        (field "duration" int)
        (maybe <| field "year" int)
        (field "songs" <| list Ws.DTO.SongSummary.decode)


convert : Album -> Entities.Album.Album
convert album =
    { id = album.id
    , artId = album.artId
    , name = album.name
    , songs = List.map Ws.DTO.SongSummary.convert album.songs
    }
