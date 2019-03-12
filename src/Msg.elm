module Msg exposing (Msg(..))

import Browser
import Rest.Msg
import Url
import Ws.Msg


type Msg
    = OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | LogOut
    | RestMsg Rest.Msg.Msg
    | WsMsg Ws.Msg.Msg
