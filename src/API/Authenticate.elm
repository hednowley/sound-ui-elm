module API.Authenticate exposing (authenticate)

import Http
import Model
import Msg
import JSON.Authenticate
import JSON.Credentials
import Config

authenticate : Model.Model -> Cmd Msg.Msg
authenticate model =
    Http.post
        { body = (Http.jsonBody << JSON.Credentials.credentialsEncoder) model
        , url = Config.root ++ "/api/authenticate"
        , expect = Http.expectJson Msg.GotAuthenticateResponse JSON.Authenticate.responseDecoder
        }