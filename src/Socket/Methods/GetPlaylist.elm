module Socket.Methods.GetPlaylist exposing (getPlaylist)

import Dict
import Entities.Album
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Socket.DTO.Album exposing (Album, convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.RequestData exposing (RequestData)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


type alias Callback =
    Entities.Album.Album -> Update Model Msg


getPlaylist : Int -> Maybe Callback -> RequestData Model
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
        Nothing
        decode
        (onSuccess callback)


onSuccess : Maybe Callback -> Album -> Update Model Msg
onSuccess callback album model =
    let
        a =
            convert album

        m =
            { model
                | songs = insertMany (.id >> getRawSongId) identity a.songs model.songs -- Store the songs
                , albums = Dict.insert a.id (Loaded a) model.albums -- Store the album
            }
    in
    case callback of
        Nothing ->
            ( m, Cmd.none )

        Just c ->
            c a m
