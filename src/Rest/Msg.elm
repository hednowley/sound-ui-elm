module Rest.Msg exposing (Msg(..))

import Http
import DTO.Authenticate


type Msg
    = GotAuthenticateResponse (Result Http.Error DTO.Authenticate.Response)
    | GotTicketResponse (Result Http.Error String)
