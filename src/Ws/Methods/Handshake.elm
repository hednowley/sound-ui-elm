module Ws.Methods.Handshake exposing (makeRequest, prepareRequest, responseDecoder)

import Json.Decode
import Json.Encode
import Model exposing (Model)
import Ws.Listener
import Ws.Types exposing (RequestData)


type alias Response =
    { accepted : Bool }


responseDecoder : Json.Decode.Decoder Response
responseDecoder =
    Json.Decode.map Response (Json.Decode.field "accepted" Json.Decode.bool)


makeRequest : String -> Json.Encode.Value
makeRequest ticket =
    Json.Encode.object
        [ ( "ticket", Json.Encode.string ticket ) ]


prepareRequest : String -> RequestData
prepareRequest ticket =
    { method = "handshake"
    , params = makeRequest ticket
    , listener = Just onResponse
    }


onResponse =
    Ws.Listener.makeListener
        responseDecoder
        (\r -> \model -> { model | message = "Logged in" })
        Nothing
        Nothing
