module Ws.Methods.GetArtists exposing (getArtists)

import Dict exposing (Dict)
import Json.Decode exposing (field, int, list, string)
import Json.Encode
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.Core as Ws
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Body =
    { artists : List Artist }


type alias Artist =
    { id : Int, name : String }


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
            (list <|
                Json.Decode.map2 Artist
                    (field "id" int)
                    (field "name" string)
            )
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
            List.map (\a -> ( a.id, a )) body.artists
    in
    ( { model | artists = Dict.fromList tuples }, Cmd.none )
