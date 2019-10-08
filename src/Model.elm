module Model exposing (Listeners(..), Model, NotificationListeners(..), PackedModel, decodeMaybePackedModel, pack)

import Browser
import Dict exposing (Dict)
import Http
import Json.Decode as Decode
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


{-| Create a storeable version of a model.
-}
pack : Model -> PackedModel
pack model =
    { username = model.username
    , password = model.password
    , message = model.message
    , isLoggedIn = model.isLoggedIn
    , token = model.token
    , scanShouldUpdate = model.scanShouldUpdate
    }


{-| A version of the model which can be stored in the browser.
-}
type alias PackedModel =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    , scanShouldUpdate : Bool
    }


{-| Decode a packed model from any JSON value.
-}
decodePackedModel : Decode.Value -> Result Decode.Error PackedModel
decodePackedModel =
    Decode.decodeValue <|
        Decode.map6 PackedModel
            (Decode.field "username" Decode.string)
            (Decode.field "password" Decode.string)
            (Decode.field "message" Decode.string)
            (Decode.field "isLoggedIn" Decode.bool)
            (Decode.field "token" (Decode.maybe Decode.string))
            (Decode.field "scanShouldUpdate" Decode.bool)


{-| Try to decode a packed model from an optional JSON value.
-}
decodeMaybePackedModel : Maybe Decode.Value -> Maybe PackedModel
decodeMaybePackedModel =
    Maybe.andThen <| Result.toMaybe << decodePackedModel
