module Msg exposing (AudioMsg(..), Msg(..))

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
    | WebsocketClosed -- The websocket has been closed
    | WebsocketIn String -- A message has been received over the websocket
    | AudioMsg AudioMsg
    | StartScan -- Ask for a scan to be started
    | PlaySong Int
    | GotAuthenticateResponse (Result Http.Error DTO.Authenticate.Response) -- Server has replied to posting of credentials
    | GotTicketResponse (Result Http.Error String) -- Server has replied to a request for a websocket ticket


type AudioMsg
    = CanPlay
    | Play
    | Pause
