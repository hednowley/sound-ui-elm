module Socket.Model exposing (Listeners(..), Model, NotificationListeners(..))

import Dict exposing (Dict)
import Msg exposing (Msg)
import Socket.Listener exposing (Listener)
import Socket.MessageId exposing (MessageId)
import Socket.NotificationListener exposing (NotificationListener)
import Socket.RequestData exposing (RequestData)


type alias Model m =
    { listeners : Listeners m
    , notificationListeners : NotificationListeners m
    , messageQueue : List ( MessageId, RequestData m )
    , nextMessageId : MessageId -- The next unused ID for a websocket message
    , isOpen : Bool
    , ticket : Maybe String
    }


{-| Everything listening out for a server response, keyed by the id of the response they listen for.
N.B. This is a type not a type alias to avoid recursion issues.
-}
type Listeners m
    = Listeners (Dict Int (Listener m Msg))


{-| Everything listening out for server notifications, keyed by the notification method they listen for.
-}
type NotificationListeners m
    = NotificationListeners (Dict String (NotificationListener m Msg))
