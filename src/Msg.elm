module Msg exposing (Msg(..))

import Browser
import Url
import Http
import JSON.Authenticate
import JSON.Scan

type Msg
    = OnUrlChange Url.Url
    | OnUrlRequest Browser.UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | SubmitLogin
    | StartScan
    | LogOut
    | GotAuthenticateResponse (Result Http.Error JSON.Authenticate.Response)
    | GotStartScanResponse (Result Http.Error JSON.Scan.Response)