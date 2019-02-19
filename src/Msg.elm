module Msg exposing (Msg(..))

import Browser
import Http
import JSON.Authenticate
import JSON.Scan
import JSON.Ticket
import Json.Encode
import Time
import Url


type Msg
    = OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | StartScan
    | LogOut
    | GotAuthenticateResponse (Result Http.Error JSON.Authenticate.Response)
    | GotScanStatusResponse (Result Http.Error JSON.Scan.Response)
    | GotTicketResponse (Result Http.Error String)
    | ScannerTick Time.Posix
    | WebsocketIn String
    | OpenWebsocket String
    | WebsocketOpened Bool
