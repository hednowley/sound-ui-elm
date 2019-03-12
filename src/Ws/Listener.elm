module Ws.Listener exposing (Listener, makeListener)

import Json.Decode exposing (Decoder, Value)


type alias Listener model =
    Result Value Value -> model -> model


makeListener : Decoder a -> (a -> model -> model) -> Maybe (Decoder b) -> Maybe (b -> model -> model) -> Listener model
makeListener successDecoder onSuccess errorDecoder onError result =
    case result of
        Ok response ->
            processSuccess response successDecoder onSuccess

        Err error ->
            processError error errorDecoder onError


processSuccess : Value -> Decoder a -> (a -> model -> model) -> model -> model
processSuccess json decoder run =
    let
        bodyResult =
            Json.Decode.decodeValue decoder json
    in
    case bodyResult of
        Ok body ->
            run body

        Err error ->
            \m -> m


processError : Value -> Maybe (Decoder a) -> Maybe (a -> model -> model) -> model -> model
processError json maybeDecoder maybeRun =
    case maybeDecoder of
        Just decoder ->
            let
                bodyResult =
                    Json.Decode.decodeValue decoder json
            in
            case bodyResult of
                Ok body ->
                    \m -> m

                Err error ->
                    \m -> m

        Nothing ->
            \m -> m