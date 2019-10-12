module Rest.Core exposing (authenticate, getTicket, gotAuthenticateResponse, gotTicketResponse)

import DTO.Authenticate
import DTO.Credentials
import DTO.Ticket
import Http exposing (Error(..))
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)
import Types exposing (Update)
import Ws.Core


{-| Post credentials to the server.
-}
authenticate : String -> Update Model Msg
authenticate password model =
    let
        credentials =
            DTO.Credentials.credentialsEncoder model.username password
    in
    ( { model | token = Loading }
    , Http.post
        { body = Http.jsonBody credentials
        , url = model.config.root ++ "/api/authenticate"
        , expect = Http.expectJson GotAuthenticateResponse DTO.Authenticate.decode
        }
    )


{-| Parse a response from the server to credentials. If it's worked then the response will be a JWT.
-}
gotAuthenticateResponse : Result Http.Error DTO.Authenticate.Response -> Update Model Msg
gotAuthenticateResponse response model =
    case response of
        Ok result ->
            case result of
                -- We got a token
                Ok token ->
                    ( { model | token = Loaded token }, getTicket model token )

                -- Server has told us why we can't have a token
                Err e ->
                    ( { model | message = e, token = Absent }, Cmd.none )

        -- We don't understand what the server said
        Err e ->
            let
                message =
                    case e of
                        BadStatus s ->
                            "BadStatus: " ++ fromInt s

                        Timeout ->
                            "Timeout"

                        NetworkError ->
                            "NetworkError"

                        BadUrl _ ->
                            "BadUrl"

                        BadBody bb ->
                            "BadBody: " ++ bb
            in
            ( { model | message = message, token = Absent }, Cmd.none )


{-| Ask the server for a websocket ticket, using our JWT.
-}
getTicket : Model -> String -> Cmd Msg
getTicket model token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = model.config.root ++ "/api/ticket"
        , expect = Http.expectJson GotTicketResponse DTO.Ticket.decode
        }


{-| The server replied to a request for a websocket ticket.
-}
gotTicketResponse : Result Http.Error String -> Update Model Msg
gotTicketResponse response model =
    case response of
        Ok ticket ->
            Ws.Core.open ticket model

        Err _ ->
            ( { model | message = "Could not retrieve websocket ticket" }, Cmd.none )
