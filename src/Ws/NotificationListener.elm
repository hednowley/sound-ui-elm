module Ws.NotificationListener exposing (NotificationListener, makeListener, makeListenerWithParams)

import Json.Decode exposing (Decoder, Value)
import Types exposing (Update)
import Ws.Notification exposing (Notification)


type alias NotificationListener model msg =
    Notification -> Update model msg


noOp : model -> model
noOp model =
    model


makeListenerWithParams : Decoder a -> (a -> Update model msg) -> NotificationListener model msg
makeListenerWithParams paramsDecoder updater notification model =
    case notification.params of
        Just params ->
            let
                bodyResult =
                    Json.Decode.decodeValue paramsDecoder params
            in
            case bodyResult of
                Ok body ->
                    updater body model

                Err error ->
                    ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


makeListener : Update model msg -> NotificationListener model msg
makeListener updater notification =
    updater
