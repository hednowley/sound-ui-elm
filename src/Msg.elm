module Msg exposing (Msg(..))

import Browser
import DTO.Authenticate
import Http
import Url


type Msg
    = NoOp
    | OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | LogOut
    | WebsocketOpened Bool
    | WebsocketIn String -- Message has been received from server
    | OpenWebsocket
    | CloseWebsocket
    | StartScan -- Ask for a scan to be started
    | GotAuthenticateResponse (Result Http.Error DTO.Authenticate.Response)
    | GotTicketResponse (Result Http.Error String)
