module Album.Update exposing (playAlbum)

import Album.Fetch exposing (fetchAlbum)
import Album.Select exposing (getAlbumSongs)
import Album.Types exposing (AlbumId)
import Audio.AudioMsg exposing (AudioMsg(..))
import Entities.Album exposing (Album)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Player.Actions exposing (replacePlaylist)
import Types exposing (Update)


playLoadedAlbum : Album -> Update Model Msg
playLoadedAlbum album =
    let
        playlist =
            List.map .id (getAlbumSongs album)
    in
    replacePlaylist playlist


playAlbum : AlbumId -> Update Model Msg
playAlbum albumId =
    fetchAlbum
        (Just playLoadedAlbum)
        albumId
