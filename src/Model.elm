module Model exposing (Model, PackedModel, Listeners(..), pack, unpack)

import Browser
import Dict exposing (Dict)
import Http
import Url
import Ws.Listener
import Time
import Rest.Msg
import Msg exposing (Msg)


type alias Model = 
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    , websocketTicket : Maybe String
    , isScanning : Bool
    , scanCount : Maybe Int
    , websocketListeners : Listeners
    , websocketId : Int
    }

type Listeners = Listeners (Dict Int (Ws.Listener.Listener Model))


pack : Model -> PackedModel
pack model =
    { username = model.username
    , password = model.password
    , message = model.message
    , isLoggedIn = model.isLoggedIn
    , token = model.token
    , isScanning = model.isScanning
    , scanCount = model.scanCount
    }

unpack : PackedModel -> Model
unpack packed =
    { username = packed.username
    , password = packed.password
    , message = packed.message
    , isLoggedIn = packed.isLoggedIn
    , token = packed.token
    , websocketTicket = Nothing
    , isScanning = packed.isScanning
    , scanCount = packed.scanCount
    , websocketListeners = Listeners Dict.empty
    , websocketId = 1
    }


type alias PackedModel =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    , isScanning : Bool
    , scanCount : Maybe Int
    }