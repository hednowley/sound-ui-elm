module Ws.Listener exposing (Listener, makeListener)

import Json.Decode exposing (Decoder, Value, decodeValue)
import Ws.Response exposing (ResponseBody)


{-| Describes how to transform the model with an incoming websocket message.
-}
type alias Listener model =
    ResponseBody -> model -> model


{-| Make a new listener. Error handling is optional, hence the Maybes.
-}
makeListener : Decoder a -> (a -> model -> model) -> Maybe (Decoder b) -> Maybe (b -> model -> model) -> Listener model
makeListener successDecoder onSuccess errorDecoder onError response =
    case response of
        Ok success ->
            processSuccess success successDecoder onSuccess

        Err error ->
            processError error errorDecoder onError


processSuccess : Value -> Decoder a -> (a -> model -> model) -> model -> model
processSuccess json decoder update =
    case decodeValue decoder json of
        Ok body ->
            update body

        Err error ->
            \m -> m


processError : Value -> Maybe (Decoder a) -> Maybe (a -> model -> model) -> model -> model
processError json maybeDecoder maybeRun =
    case maybeDecoder of
        Just decoder ->
            case decodeValue decoder json of
                Ok body ->
                    \m -> m

                Err error ->
                    \m -> m

        Nothing ->
            \m -> m
