module Playlist.Fetch exposing (fetchPlaylist)

import Dict
import Entities.Playlist exposing (Playlist)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model, addListener, removeListener)
import Msg exposing (Msg)
import Playlist.Select exposing (getPlaylistSongs)
import Types exposing (Update)
import Util exposing (insertMany)
import Ws.Core exposing (sendMessageWithId)
import Ws.DTO.Playlist exposing (convert, decode)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Callback =
    Playlist -> Update Model Msg


recordFetchingPlaylist : Int -> Int -> Model -> Model
recordFetchingPlaylist playlistId messageId model =
    { model | loadedPlaylists = Dict.insert playlistId (Loading messageId) model.loadedPlaylists }


fetchPlaylist : Int -> Maybe Callback -> Update Model Msg
fetchPlaylist playlistId maybeCallback model =
    case Playlist.Select.getPlaylist playlistId model of
        {- This playlist has never been fetched. -}
        Absent ->
            let
                ( ( newModel, cmd ), messageId ) =
                    sendMessageWithId
                        (makeFetchPlaylistMessage playlistId maybeCallback)
                        model
            in
            ( recordFetchingPlaylist playlistId messageId newModel
            , cmd
            )

        {- There is already an in-flight fetch for this playlist. -}
        Loading requestId ->
            case maybeCallback of
                Just callback ->
                    ( addListener requestId (onResponse (Just callback)) model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        {- This playlist has already been fetched -}
        Loaded playlist ->
            case maybeCallback of
                Just callback ->
                    callback playlist model

                Nothing ->
                    ( model, Cmd.none )


makeFetchPlaylistMessage : Int -> Maybe Callback -> RequestData
makeFetchPlaylistMessage id callback =
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


onSuccess : Maybe Callback -> Ws.DTO.Playlist.Playlist -> Update Model Msg
onSuccess maybeCallback dto model =
    let
        playlist =
            convert dto
    in
    let
        newModel =
            { model
                | songs = insertMany .id identity playlist.songs model.songs -- Store the songs
                , loadedPlaylists = Dict.insert playlist.id (Loaded playlist) model.loadedPlaylists -- Store the playlist
            }
    in
    case maybeCallback of
        Nothing ->
            ( newModel, Cmd.none )

        Just callback ->
            callback playlist newModel
