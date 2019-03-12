module WebsocketListener exposing (WebsocketListener)

import Msg exposing (..)


type alias WebsocketListener = String -> Cmd Msg
