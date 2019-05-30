module Msg exposing (Msg(..))

import Browser
import DTO.Authenticate
import Http
import Url
import Ws.Msg


type Msg
    = OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | LogOut
    | WsMsg Ws.Msg.Msg
    | GotAuthenticateResponse (Result Http.Error DTO.Authenticate.Response)
    | GotTicketResponse (Result Http.Error String)
