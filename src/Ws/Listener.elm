module Ws.Listener exposing (Listener, makeIrresponsibleListener, makeResponsibleListener)

import Json.Decode exposing (Decoder, Value, decodeValue)
import Types exposing (Update, noOp)
import Ws.Response exposing (Response)


{-| Describes how to transform the model and dispatch commands with an incoming websocket message.
First parameter is the ID of the incoming message.
-}
type alias Listener model msg =
    Response -> Update model msg


{-| Make a new listener which has error handling.
-}
makeResponsibleListener :
    (Response -> model -> model)
    -> Decoder a
    -> (a -> Update model msg)
    -> Decoder b
    -> (b -> Update model msg)
    -> Listener model msg
makeResponsibleListener cleanup successDecoder onSuccess errorDecoder onError response model =
    let
        cleaned =
            cleanup response model
    in
    case response.body of
        Ok success ->
            processSuccess success successDecoder onSuccess cleaned

        Err error ->
            processError error errorDecoder onError cleaned


{-| Make a new listener which has no error handling.
-}
makeIrresponsibleListener :
    (Response -> model -> model)
    -> Decoder a
    -> (a -> Update model msg)
    -> Listener model msg
makeIrresponsibleListener cleanup successDecoder onSuccess response model =
    let
        cleaned =
            cleanup response model
    in
    case response.body of
        Ok success ->
            processSuccess success successDecoder onSuccess cleaned

        Err error ->
            ( cleaned, Cmd.none )


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
