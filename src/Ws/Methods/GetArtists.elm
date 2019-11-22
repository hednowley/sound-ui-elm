module Ws.Methods.GetArtists exposing (getArtists)

import Artist.Types exposing (ArtistId, getRawArtistId)
import Dict
import Json.Decode exposing (field, int, list, string)
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.DTO.ArtistSummary exposing (convert, decode)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Body =
    { artists : List Artist }


type alias Artist =
    { id : Int
    , name : String
    }


getArtists : RequestData
getArtists =
    { method = "getArtists"
    , params = Nothing
    , listener = Just onResponse
    }


responseDecoder : Json.Decode.Decoder Body
responseDecoder =
    Json.Decode.map Body
        (field "artists"
            (list decode)
        )


onResponse : Listener Model Msg
onResponse =
    makeIrresponsibleListener
        (.id >> removeListener)
        responseDecoder
        setArtists


setArtists : Body -> Update Model Msg
setArtists body model =
    let
        tuples =
            List.map (\a -> ( a.id, convert a )) body.artists
    in
    ( { model | artists = Dict.fromList tuples }, Cmd.none )
