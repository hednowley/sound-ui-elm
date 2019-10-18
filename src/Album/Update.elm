module Album.Update exposing (loadAlbum, playAlbum)

import Album.Select exposing (getAlbumSongs)
import Audio.Update exposing (replacePlaylist)
import Dict
import Entities.Album exposing (Album)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Types exposing (Update)
import Ws.Core exposing (sendMessage)
import Ws.Methods.GetAlbum exposing (getAlbum)


loadAlbum : Int -> Maybe (Album -> Update Model Msg) -> Update Model Msg
loadAlbum id callback model =
    sendMessage
        (getAlbum id callback)
        { model | albums = Dict.insert id Loading model.albums }


playAlbum2 : Album -> Update Model Msg
playAlbum2 album model =
    let
        playlist =
            List.map .id (getAlbumSongs album model)
    in
    replacePlaylist playlist model


playAlbum : Int -> Update Model Msg
playAlbum albumId =
    loadAlbum albumId (Just playAlbum2)
