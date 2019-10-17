module Album.Update exposing (playAlbum)

import Album.Select exposing (..)
import Array exposing (fromList)
import Audio.Update exposing (..)
import Entities.Album exposing (Album)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Types exposing (Update, combine)


playAlbum : Album -> Update Model Msg
playAlbum album model =
    let
        playlist =
            List.map .id (getAlbumSongs album model)
    in
    replacePlaylist playlist model
