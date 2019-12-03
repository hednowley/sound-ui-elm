module Album.Fetch exposing (fetchAlbum)

import Album.Types exposing (AlbumId, getRawAlbumId)
import Dict
import Entities.Album exposing (Album)
import Entities.Playlist exposing (Playlist)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Nexus.Fetch exposing (fetch)
import Playlist.Select
import Socket.Actions exposing (addListenerExternal)
import Socket.Core exposing (sendMessageWithId)
import Socket.DTO.Album exposing (convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.MessageId exposing (MessageId)
import Socket.RequestData exposing (RequestData)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


fetchAlbum : Maybe (Album -> Update Model Msg) -> AlbumId -> Update Model Msg
fetchAlbum maybeCallback =
    fetch
        getRawAlbumId
        "getAlbum"
        decode
        convert
        .loadedAlbums
        (\repo -> \m -> { m | loadedAlbums = repo })
        saveSongs
        maybeCallback


saveSongs : Album -> Model -> Model
saveSongs album model =
    { model
        | songs =
            insertMany
                (.id >> getRawSongId)
                identity
                album.songs
                model.songs
    }
