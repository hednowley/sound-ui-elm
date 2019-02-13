module API.Scan exposing (startScan, getStatus)

import Http
import JSON.Scan
import Model
import Msg
import Config


startScan : Model.Model -> Cmd Msg.Msg
startScan model =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ Maybe.withDefault "" model.token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = Config.root ++ "/api/startscan"
        , expect = Http.expectJson Msg.GotScanStatusResponse JSON.Scan.responseDecoder
        }


getStatus : Model.Model -> Cmd Msg.Msg
getStatus model =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ Maybe.withDefault "" model.token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = Config.root ++ "/api/getscanstatus"
        , expect = Http.expectJson Msg.GotScanStatusResponse JSON.Scan.responseDecoder
        }
