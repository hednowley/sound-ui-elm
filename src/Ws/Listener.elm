module Ws.Listener exposing (Listener, makeListener)

import Json.Decode exposing (Decoder, Value, decodeValue)
import Types exposing (Update, noOp)
import Ws.Response exposing (ResponseBody)


{-| Describes how to transform the model with an incoming websocket message.
-}
type alias Listener model msg =
    ResponseBody -> Update model msg


{-| Make a new listener without error handling.
-}
makeListener :
    Decoder a
    -> (a -> Update model msg)
    -> Listener model msg
makeListener successDecoder onSuccess response =
    case response of
        Ok success ->
            processSuccess success successDecoder onSuccess

        Err error ->
            noOp


{-| Make a new listener which has eror handling.
-}
makeResponsibleListener :
    Decoder a
    -> (a -> Update model msg)
    -> Decoder b
    -> (b -> Update model msg)
    -> Listener model msg
makeResponsibleListener successDecoder onSuccess errorDecoder onError response =
    case response of
        Ok success ->
            processSuccess success successDecoder onSuccess

        Err error ->
            processError error errorDecoder onError


processSuccess : Value -> Decoder a -> (a -> Update model msg) -> Update model msg
processSuccess json decoder update =
    case decodeValue decoder json of
        Ok body ->
            update body

        Err error ->
            noOp


processError : Value -> Decoder a -> (a -> Update model msg) -> Update model msg
processError json decoder update =
    case decodeValue decoder json of
        Ok body ->
            noOp

        Err error ->
            noOp
