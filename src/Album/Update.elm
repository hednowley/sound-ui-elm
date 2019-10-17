module Album.Update exposing (playAlbum)

import Album.Select exposing (..)
import Array exposing (fromList)
import Audio.Update exposing (..)
import Entities.Album exposing (Album)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Types exposing (Update, combine)


playAlbum2 : Album -> Update Model Msg
playAlbum2 album model =
    let
        playlist =
            List.map .id (getAlbumSongs album model)
    in
    playItem 0 { model | playlist = fromList playlist }


playAlbum : Album -> Update Model Msg
playAlbum album =
    combine
        pauseCurrent
        (playAlbum2 album)
