module API.Ticket exposing (getTicket)

import Http
import Model
import Msg
import JSON.Ticket
import Config

getTicket : String -> Cmd Msg.Msg
getTicket token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = Config.root ++ "/api/ticket"
        , expect = Http.expectJson Msg.GotTicketResponse JSON.Ticket.responseDecoder
        }