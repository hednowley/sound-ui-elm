module Ws.Methods.Handshake exposing (makeRequest, prepareRequest)

import Json.Decode
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update, noOp)
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
prepareRequest : String -> Update Model Msg -> RequestData
prepareRequest ticket onHandshakeSuccess =
    { method = "handshake"
    , params = makeRequest ticket
    , listener = Just (onResponse onHandshakeSuccess)
    }


onResponse : Update Model Msg -> Listener Model Msg
onResponse onHandshakeSuccess =
    Ws.Listener.makeListener
        responseDecoder
        (onSuccess onHandshakeSuccess)


onSuccess : Update Model Msg -> Response -> Update Model Msg
onSuccess onHandshakeSuccess response model =
    if response.accepted then
        onHandshakeSuccess { model | message = "Websocket handshake succeeded" }

    else
        ( { model | message = "Websocket handshake failed" }, Cmd.none )
