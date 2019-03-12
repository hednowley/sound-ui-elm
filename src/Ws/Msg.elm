module Ws.Msg exposing (Msg(..))


type Msg
    = WebsocketOpened Bool
    | WebsocketIn String
    | OpenWebsocket String
    | StartScan
