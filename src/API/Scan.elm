module API.Scan exposing (startScan)

import Http
import Model
import Msg
import JSON.Scan

startScan : Model.Model -> Cmd Msg.Msg
startScan model =
    Http.request
        { method = "POST"
        , headers = []
        , body = Http.emptyBody 
        , timeout = Nothing
        , tracker = Nothing
        , url = "http://hednowley.synology.me:171/api/startScan"
        , expect = Http.expectJson Msg.GotStartScanResponse JSON.Scan.responseDecoder
        }