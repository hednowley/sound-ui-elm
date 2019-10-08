module Ws.Methods.Handshake exposing (makeRequest, prepareRequest)

import Json.Decode
import Json.Encode
import Model exposing (Model)
import Ws.Listener exposing (Listener)
import Ws.Types exposing (RequestData)


type alias Response =
    { accepted : Bool }


responseDecoder : Json.Decode.Decoder Response
responseDecoder =
    Json.Decode.map Response
        (Json.Decode.field "accepted" Json.Decode.bool)


makeRequest : String -> Json.Encode.Value
makeRequest ticket =
    Json.Encode.object
        [ ( "ticket", Json.Encode.string ticket ) ]


{-| Make a message which starts the websocket handshake.
-}
prepareRequest : String -> (Model -> Model) -> RequestData
prepareRequest ticket onHandshakeSuccess =
    { method = "handshake"
    , params = makeRequest ticket
    , listener = Just (onResponse onHandshakeSuccess)
    }


onResponse : (Model -> Model) -> Listener Model
onResponse onHandshakeSuccess =
    Ws.Listener.makeListener
        responseDecoder
        (onSuccess onHandshakeSuccess)
        Nothing
        Nothing


onSuccess : (Model -> Model) -> Response -> Model -> Model
onSuccess onHandshakeSuccess response model =
    if response.accepted then
        onHandshakeSuccess { model | message = "Websocket handshake succeeded" }

    else
        { model | message = "Websocket handshake failed" }
