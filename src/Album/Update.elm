module Album.Update exposing (playAlbum)

import Album.Select exposing (getAlbumSongs)
import Audio.Update exposing (replacePlaylist)
import Entities.Album exposing (Album)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Types exposing (Update)


playAlbum : Int -> Update Model Msg
playAlbum albumId model =
    let
        playlist =
            List.map .id (getAlbumSongs album model)
    in
    replacePlaylist playlist model
