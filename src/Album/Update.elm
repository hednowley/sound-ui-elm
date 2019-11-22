module Album.Update exposing (loadAlbum, playAlbum)

import Album.Select exposing (getAlbumSongs)
import Album.Types exposing (AlbumId, getRawAlbumId)
import Audio.Actions exposing (replacePlaylist)
import Audio.AudioMsg exposing (AudioMsg(..))
import Dict
import Entities.Album exposing (Album)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (Update)
import Ws.Core exposing (sendMessageWithId)
import Ws.Methods.GetAlbum exposing (getAlbum)


loadAlbum : AlbumId -> Maybe (Album -> Update Model Msg) -> Update Model Msg
loadAlbum id callback model =
    let
        ( ( newModel, cmd ), messageId ) =
            sendMessageWithId
                (getAlbum id callback)
                model
    in
    ( { newModel
        | albums =
            Dict.insert (getRawAlbumId id) (Loading messageId) newModel.albums
      }
    , cmd
    )


playLoadedAlbum : Album -> Update Model Msg
playLoadedAlbum album =
    let
        playlist =
            List.map .id (getAlbumSongs album)
    in
    replacePlaylist playlist


playAlbum : AlbumId -> Update Model Msg
playAlbum albumId =
    loadAlbum
        albumId
        (Just playLoadedAlbum)
