module Msg exposing (Msg(..))

import Browser
import Url
import Http
import JSON.Authenticate
import JSON.Scan
import Time

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
    | ScannerTick Time.Posix