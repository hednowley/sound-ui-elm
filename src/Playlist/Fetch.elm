module Playlist.Fetch exposing (fetchPlaylist)

import Dict
import Entities.Playlist exposing (Playlist)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Playlist.Select exposing (getPlaylistSongs)
import Socket.Actions exposing (addListenerExternal)
import Socket.Core exposing (sendMessageWithId)
import Socket.DTO.Playlist exposing (convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.RequestData exposing (RequestData)
import Socket.Types exposing (MessageId)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


type alias Callback =
    Playlist -> Update Model Msg


recordFetchingPlaylist : Int -> MessageId -> Model -> Model
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
                        False
                        model
            in
            ( recordFetchingPlaylist playlistId messageId newModel
            , cmd
            )

        {- There is already an in-flight fetch for this playlist. -}
        Loading requestId ->
            case maybeCallback of
                Just callback ->
                    ( addListenerExternal requestId (onResponse (Just callback)) model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        {- This playlist has already been fetched -}
        Loaded playlist ->
            case maybeCallback of
                Just callback ->
                    callback playlist model

                Nothing ->
                    ( model, Cmd.none )


makeFetchPlaylistMessage : Int -> Maybe Callback -> RequestData Model
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
        Nothing
        decode
        (onSuccess callback)


onSuccess : Maybe Callback -> Socket.DTO.Playlist.Playlist -> Update Model Msg
onSuccess maybeCallback dto model =
    let
        playlist =
            convert dto
    in
    let
        newModel =
            { model
                | songs =
                    insertMany
                        (.id >> getRawSongId)
                        identity
                        playlist.songs
                        model.songs

                -- Store the songs
                , loadedPlaylists = Dict.insert playlist.id (Loaded playlist) model.loadedPlaylists -- Store the playlist
            }
    in
    case maybeCallback of
        Nothing ->
            ( newModel, Cmd.none )

        Just callback ->
            callback playlist newModel
