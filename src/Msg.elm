module Msg exposing (Msg(..))

import Browser
import DTO.Authenticate
import Http
import Url


type Msg
    = OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | LogOut
    | ToggleScanUpdate
    | ToggleScanDelete
    | WebsocketOpened -- The websocket has been successfully opened
    | WebsocketIn String -- A message has been received over the websocket
    | OpenWebsocket String -- Open a new websocket
    | StartScan -- Ask for a scan to be started
    | GotAuthenticateResponse (Result Http.Error DTO.Authenticate.Response) -- Server has replied to posting of credentials
    | GotTicketResponse (Result Http.Error String) -- Server has replied to a request for a websocket ticket
