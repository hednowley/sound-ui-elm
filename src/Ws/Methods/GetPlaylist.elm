module Ws.Methods.GetPlaylist exposing (getPlaylist)

import Dict
import Entities.Album
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Util exposing (insertMany)
import Ws.DTO.Album exposing (Album, convert, decode)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Callback =
    Entities.Album.Album -> Update Model Msg


getPlaylist : Int -> Maybe Callback -> RequestData
getPlaylist id callback =
    { method = "getPlaylist"
    , params = Just (makeRequest id)
    , listener = Just (onResponse callback)
    }


makeRequest : Int -> Json.Encode.Value
makeRequest id =
    Json.Encode.object
        [ ( "id", Json.Encode.int id ) ]


onResponse : Maybe Callback -> Listener Model Msg
onResponse callback =
    makeIrresponsibleListener
        (.id >> removeListener)
        decode
        (onSuccess callback)


onSuccess : Maybe Callback -> Album -> Update Model Msg
onSuccess callback album model =
    let
        a =
            convert album

        m =
            { model
                | songs = insertMany .id identity a.songs model.songs -- Store the songs
                , albums = Dict.insert a.id (Loaded a) model.albums -- Store the album
            }
    in
    case callback of
        Nothing ->
            ( m, Cmd.none )

        Just c ->
            c a m
