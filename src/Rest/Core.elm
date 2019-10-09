module Rest.Core exposing (authenticate, getTicket, gotAuthenticateResponse, gotTicketResponse)

import Config
import DTO.Authenticate
import DTO.Credentials
import DTO.Ticket
import Http exposing (Error(..))
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports


{-| Post credentials to the server.
-}
authenticate : Model -> Cmd Msg
authenticate model =
    Http.post
        { body = Http.jsonBody <| DTO.Credentials.credentialsEncoder model.username model.password
        , url = Config.root ++ "/api/authenticate"
        , expect = Http.expectJson GotAuthenticateResponse DTO.Authenticate.responseDecoder
        }


{-| Ask the server for a websocket ticket, using our JWT.
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


{-| Parse a response from the server to credentials. If it's worked then the response will be a JWT.
-}
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

        Err e ->
            let
                message =
                    case e of
                        BadStatus _ ->
                            "BadStatus"

                        Timeout ->
                            "Timeout"

                        NetworkError ->
                            "NetworkError"

                        BadUrl _ ->
                            "BadUrl"

                        BadBody _ ->
                            "BadBody"
            in
            ( { model | message = message }, Cmd.none )


{-| The server replied to a request for a websocket ticket.
-}
gotTicketResponse : (Msg -> Model -> ( Model, Cmd Msg )) -> Result Http.Error String -> Model -> ( Model, Cmd Msg )
gotTicketResponse update response model =
    case response of
        Ok r ->
            update
                OpenWebsocket
                { model | websocketTicket = Just r }

        Err _ ->
            ( model, Cmd.none )
