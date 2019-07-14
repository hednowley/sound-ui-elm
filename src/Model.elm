module Model exposing (Listeners(..), Model, NotificationListeners(..), PackedModel, pack)

import Browser
import Dict exposing (Dict)
import Http
import Msg exposing (Msg)
import Time
import Url
import Ws.Listener exposing (Listener)
import Ws.NotificationListener exposing (NotificationListener)


type alias Model =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String 
    , websocketTicket : Maybe String
    , isScanning : Bool
    , scanCount : Int
    , websocketListeners : Listeners
    , notificationListeners : NotificationListeners
    , websocketId : Int
    , scanShouldUpdate : Bool
    , scanShouldDelete : Bool
    }


{-| Everything listening out for a server response, keyed by the id of the response they listen for.
-}
type Listeners
    = Listeners (Dict Int (Listener Model))


{-| Everything listening out for server notifications, keyed by the notification method they listen for.
-}
type NotificationListeners
    = NotificationListeners (Dict String (NotificationListener Model))


pack : Model -> PackedModel
pack model =
    { username = model.username
    , password = model.password
    , message = model.message
    , isLoggedIn = model.isLoggedIn
    , token = model.token
    , scanShouldUpdate = model.scanShouldUpdate
    }


type alias PackedModel =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    , scanShouldUpdate : Bool
    }
