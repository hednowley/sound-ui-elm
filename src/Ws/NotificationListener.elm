module Ws.NotificationListener exposing (NotificationListener, makeListener, makeListenerWithParams)

import Json.Decode exposing (Decoder, Value)
import Ws.Notification exposing (Notification)


type alias NotificationListener model =
    Notification -> model -> model


noOp : model -> model
noOp model =
    model


makeListenerWithParams : Decoder a -> (a -> model -> model) -> NotificationListener model
makeListenerWithParams paramsDecoder updater notification =
    case notification.params of
        Just params ->
            let
                bodyResult =
                    Json.Decode.decodeValue paramsDecoder params
            in
            case bodyResult of
                Ok body ->
                    updater body

                Err error ->
                    noOp

        Nothing ->
            noOp


makeListener : (model -> model) -> NotificationListener model
makeListener updater notification =
    updater
