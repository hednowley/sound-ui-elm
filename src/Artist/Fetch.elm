module Artist.Fetch exposing (fetchArtist)

import Artist.Types exposing (ArtistId, getRawArtistId)
import Dict
import Entities.Artist exposing (Artist)
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
import Socket.DTO.Artist exposing (convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.MessageId exposing (MessageId)
import Socket.RequestData exposing (RequestData)
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update)
import Util exposing (insertMany)


fetchArtist : Maybe (Artist -> Update Model Msg) -> ArtistId -> Update Model Msg
fetchArtist maybeCallback =
    fetch
        getRawArtistId
        "getArtist"
        decode
        convert
        .loadedArtists
        (\repo -> \m -> { m | loadedArtists = repo })
        (\o -> \m -> m)
        maybeCallback
