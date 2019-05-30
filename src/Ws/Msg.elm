module Ws.Msg exposing (Msg(..))


type Msg
    = WebsocketOpened Bool
    | WebsocketIn String -- Message has been received from server
    | OpenWebsocket
    | CloseWebsocket
    | StartScan -- Ask for a scan to be started
