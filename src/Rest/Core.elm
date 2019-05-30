module Rest.Core exposing (authenticate, getTicket, gotAuthenticateResponse, gotTicketResponse)

import Config
import DTO.Authenticate
import DTO.Credentials
import DTO.Ticket
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports
import Types exposing (Update)


authenticate : Model -> Cmd Msg
authenticate model =
    Http.post
        { body = Http.jsonBody <| DTO.Credentials.credentialsEncoder model.username model.password
        , url = Config.root ++ "/api/authenticate"
        , expect = Http.expectJson GotAuthenticateResponse DTO.Authenticate.responseDecoder
        }


{-| Tries to connect to the websocket.
-}
getTicket : String -> Cmd Msg
getTicket token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = Config.root ++ "/api/ticket"
        , expect = Http.expectJson GotTicketResponse DTO.Ticket.responseDecoder
        }


gotAuthenticateResponse : Result Http.Error DTO.Authenticate.Response -> Model -> ( Model, Cmd Msg )
gotAuthenticateResponse response model =
    case response of
        Ok r ->
            ( { model
                | message = ""
                , isLoggedIn = True
                , token = Just r.token
              }
            , getTicket r.token
            )

        Err _ ->
            ( { model | message = "Error!" }, Cmd.none )


gotTicketResponse : Update -> Result Http.Error String -> Model -> ( Model, Cmd Msg )
gotTicketResponse update response model =
    case response of
        Ok r ->
            update
                OpenWebsocket
                { model | websocketTicket = Just r }

        Err _ ->
            ( model, Cmd.none )
