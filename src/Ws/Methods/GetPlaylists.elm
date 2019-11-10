module Ws.Methods.GetPlaylists exposing (getPlaylists)

import Dict
import Json.Decode exposing (field, int, list, string)
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Body =
    { playlists : List Playlist }


type alias Playlist =
    { id : Int
    , name : String
    }


getPlaylists : RequestData
getPlaylists =
    { method = "getPlaylists"
    , params = Nothing
    , listener = Just onResponse
    }


responseDecoder : Json.Decode.Decoder Body
responseDecoder =
    Json.Decode.map Body
        (field "playlists"
            (list <|
                Json.Decode.map2 Playlist
                    (field "id" int)
                    (field "name" string)
            )
        )


onResponse : Listener Model Msg
onResponse =
    makeIrresponsibleListener
        (.id >> removeListener)
        responseDecoder
        setPlaylists


setPlaylists : Body -> Update Model Msg
setPlaylists body model =
    let
        tuples =
            List.map (\a -> ( a.id, a )) body.playlists
    in
    ( { model | artists = Dict.fromList tuples }, Cmd.none )
