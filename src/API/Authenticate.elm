module API.Authenticate exposing (authenticate)

import Http
import Model
import Msg
import JSON.Authenticate

authenticate : Model.Model -> Cmd Msg.Msg
authenticate model =
    Http.post
        { body = (Http.jsonBody << JSON.Authenticate.userEncoder) model
        , url = "http://hednowley.synology.me:171/api/authenticate"
        , expect = Http.expectJson Msg.GotAuthenticateResponse JSON.Authenticate.responseDecoder
        }