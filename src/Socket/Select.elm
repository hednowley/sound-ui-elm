module Socket.Select exposing (getListener, getNotificationListener)

import Dict exposing (Dict)
import Model
import Msg exposing (Msg)
import Socket.Listener exposing (Listener)
import Socket.Model exposing (Listeners(..), NotificationListeners(..))
import Socket.NotificationListener exposing (NotificationListener)
import Socket.Types exposing (MessageId, getRawMessageId)


type alias Model =
    Socket.Model.Model Model.Model


{-| Try and retrieve the listener with the given ID.
-}
getListener : MessageId -> Model -> Maybe (Listener Model.Model Msg)
getListener id model =
    let
        (Listeners listeners) =
            model.listeners
    in
    Dict.get (getRawMessageId id) listeners


{-| Try and retrieve the notification listener for the given method.
-}
getNotificationListener : String -> Model -> Maybe (NotificationListener Model.Model Msg)
getNotificationListener method model =
    let
        (NotificationListeners listeners) =
            model.notificationListeners
    in
    Dict.get method listeners
