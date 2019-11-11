module Model exposing
    ( Listeners(..)
    , Model
    , NotificationListeners(..)
    , addListener
    , getListener
    , getNotificationListener
    , removeListener
    )

import Array exposing (Array)
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
import Msg exposing (Msg)
import Routing exposing (Route)
import Url exposing (Url)
import Ws.Listener exposing (Listener)
import Ws.NotificationListener exposing (NotificationListener)


type alias Model =
    { key : Key
    , url : Url
    , username : String
    , password : String
    , message : String
    , token : Loadable String
    , websocketTicket : Maybe String
    , isScanning : Bool
    , scanCount : Int
    , websocketListeners : Listeners
    , notificationListeners : NotificationListeners
    , websocketId : Int -- The next unused ID for a websocket message
    , scanShouldUpdate : Bool
    , scanShouldDelete : Bool
    , playlists : PlaylistSummaries
    , artists : ArtistSummaries
    , artist : Loadable Artist
    , currentPlaylist : Loadable Playlist
    , songs : Dict Int SongSummary
    , albums : Dict Int (Loadable Album)
    , config : Config
    , websocketIsOpen : Bool
    , route : Maybe Route
    , songCache : Dict Int AudioState.State
    , playing : Maybe Int
    , playlist : Array Int
    }


{-| Everything listening out for a server response, keyed by the id of the response they listen for.
N.B. This is a type not a type alias to avoid recursion issues.
-}
type Listeners
    = Listeners (Dict Int (Listener Model Msg))


{-| Try and retrieve the listener with the given ID.
-}
getListener : Int -> Model -> Maybe (Listener Model Msg)
getListener id model =
    let
        (Listeners listeners) =
            model.websocketListeners
    in
    Dict.get id listeners


{-| Store a new Websocket listener in the model.
-}
addListener : Int -> Listener Model Msg -> Model -> Model
addListener id listener model =
    let
        (Listeners listeners) =
            model.websocketListeners
    in
    { model
        | websocketListeners =
            Listeners <|
                Dict.insert id listener listeners
    }


{-| Remove a stored Websocket listener from the model.
-}
removeListener : Int -> Model -> Model
removeListener id model =
    let
        (Listeners listeners) =
            model.websocketListeners
    in
    { model
        | websocketListeners =
            Listeners <|
                Dict.remove id listeners
    }


{-| Everything listening out for server notifications, keyed by the notification method they listen for.
-}
type NotificationListeners
    = NotificationListeners (Dict String (NotificationListener Model Msg))


{-| Try and retrieve the notification listener for the given method.
-}
getNotificationListener : String -> Model -> Maybe (NotificationListener Model Msg)
getNotificationListener method model =
    let
        (NotificationListeners listeners) =
            model.notificationListeners
    in
    Dict.get method listeners
