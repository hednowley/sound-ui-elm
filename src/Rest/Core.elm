module Rest.Core exposing (authenticate, getTicket, update)

import Config
import DTO.Authenticate
import DTO.Credentials
import DTO.Ticket
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode
import Model exposing (Model)
import Ports
import Rest.Msg


authenticate : Model -> Cmd Rest.Msg.Msg
authenticate model =
    Http.post
        { body = Http.jsonBody <| DTO.Credentials.credentialsEncoder model.username model.password
        , url = Config.root ++ "/api/authenticate"
        , expect = Http.expectJson Rest.Msg.GotAuthenticateResponse DTO.Authenticate.responseDecoder
        }


getTicket : String -> Cmd Rest.Msg.Msg
getTicket token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = Config.root ++ "/api/ticket"
        , expect = Http.expectJson Rest.Msg.GotTicketResponse DTO.Ticket.responseDecoder
        }


update : Rest.Msg.Msg -> Model -> ( Model, Cmd Rest.Msg.Msg )
update msg model =
    case msg of
        Rest.Msg.GotAuthenticateResponse response ->
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

        Rest.Msg.GotTicketResponse response ->
            case response of
                Ok r ->
                    ( { model | websocketTicket = Just r }, Ports.websocketOpen Config.ws )

                Err _ ->
                    ( model, Ports.websocketOpen "noo" )
