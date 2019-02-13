module API.Authenticate exposing (authenticate)

import Http
import Model
import Msg
import JSON.Authenticate
import Config

authenticate : Model.Model -> Cmd Msg.Msg
authenticate model =
    Http.post
        { body = (Http.jsonBody << JSON.Authenticate.userEncoder) model
        , url = Config.root ++ "/api/authenticate"
        , expect = Http.expectJson Msg.GotAuthenticateResponse JSON.Authenticate.responseDecoder
        }