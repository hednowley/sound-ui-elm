module Album.Fetch exposing (fetchAlbum)

import Album.Types exposing (AlbumId, getRawAlbumId)
import Entities.Album exposing (Album)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Nexus.Fetch exposing (fetch)
import Socket.DTO.Album exposing (convert, decode)
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
        { get = .albums
        , set = \repo -> \m -> { m | albums = repo }
        }
        saveSongs
        maybeCallback


saveSongs : Album -> Update Model Msg
saveSongs album model =
    ( { model
        | songs =
            insertMany
                (.id >> getRawSongId)
                identity
                album.songs
                model.songs
      }
    , Cmd.none
    )
