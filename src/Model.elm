module Model exposing (Model, SocketModelWrap(..), getSocketModel, setSocketModel)

import AudioState
import Browser.Navigation exposing (Key)
import Config exposing (Config)
import Dict exposing (Dict)
import Entities.Album exposing (Album)
import Entities.Artist exposing (Artist)
import Entities.ArtistSummary exposing (ArtistSummaries)
import Entities.Playlist exposing (Playlist)
import Entities.PlaylistSummary exposing (PlaylistSummaries)
import Entities.SongSummary exposing (SongSummary)
import Loadable exposing (Loadable(..))
import Player.Model
import Routing exposing (Route)
import Socket.Model
import Url exposing (Url)


type alias Model =
    { key : Key
    , url : Url
    , username : String
    , password : String
    , message : String
    , token : Loadable String
    , isScanning : Bool
    , scanCount : Int
    , scanShouldUpdate : Bool
    , scanShouldDelete : Bool
    , playlists : PlaylistSummaries
    , loadedPlaylists : Dict Int (Loadable Playlist)
    , artists : ArtistSummaries
    , artist : Loadable Artist
    , songs : Dict Int SongSummary
    , albums : Dict Int (Loadable Album)
    , config : Config 
    , route : Maybe Route
    , songCache : Dict Int AudioState.State
    , socket : SocketModelWrap
    , player : Player.Model.Model
    }


{-| Type to avoid type recursion
-}
type SocketModelWrap
    = SocketModelWrap (Socket.Model.Model Model)


getSocketModel : Model -> Socket.Model.Model Model
getSocketModel model =
    let
        (SocketModelWrap s) =
            model.socket
    in
    s


setSocketModel : Model -> Socket.Model.Model Model -> Model
setSocketModel model socket =
    { model
        | socket = SocketModelWrap socket
    }
