module Playlist.Fetch exposing (fetchPlaylist)

import Dict
import Entities.Playlist exposing (Playlist)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Nexus.Fetch exposing (fetch)
import Playlist.Select
import Playlist.Types exposing (PlaylistId, getRawPlaylistId)
import Socket.Actions exposing (addListenerExternal)
import Socket.Core exposing (sendMessageWithId)
import Socket.DTO.Playlist exposing (convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.MessageId exposing (MessageId)
import Socket.RequestData exposing (RequestData)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


type alias Callback =
    Playlist -> Update Model Msg


recordFetchingPlaylist : PlaylistId -> MessageId -> Model -> Model
recordFetchingPlaylist playlistId messageId model =
    { model | loadedPlaylists = Dict.insert (getRawPlaylistId playlistId) (Loading messageId) model.loadedPlaylists }


fetchPlaylist : Maybe Callback -> PlaylistId -> Update Model Msg
fetchPlaylist maybeCallback =
    fetch
        getRawPlaylistId
        makeFetchPlaylistMessage
        decode
        convert
        (\m -> m.loadedPlaylists)
        (\repo -> \m -> { m | loadedPlaylists = repo })
        maybeCallback


makeFetchPlaylistMessage : PlaylistId -> Listener Model Msg -> RequestData Model
makeFetchPlaylistMessage id listener =
    { method = "getPlaylist"
    , params = Just (makeRequest (getRawPlaylistId id))
    , listener = Just listener
    }


makeRequest : Int -> Json.Encode.Value
makeRequest id =
    Json.Encode.object
        [ ( "id", Json.Encode.int id ) ]


saveSongs : Playlist -> Update Model Msg
saveSongs playlist model =
    ( { model
        | songs =
            insertMany
                (.id >> getRawSongId)
                identity
                playlist.songs
                model.songs
      }
    , Cmd.none
    )
