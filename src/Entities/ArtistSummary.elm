module Entities.ArtistSummary exposing (ArtistSummaries, ArtistSummary)

import Dict exposing (Dict)


type alias ArtistSummary =
    { id : Int
    , name : String
    }


type alias ArtistSummaries =
    Dict Int ArtistSummary
