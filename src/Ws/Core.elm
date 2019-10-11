module Ws.Core exposing
    ( addListener
    , messageIn
    , open
    , sendMessage
    )

import Config exposing (getWebsocketUrl)
import Dict
import Http
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports
import Types exposing (Update)
import Ws.Listener exposing (Listener)
import Ws.Message as Message exposing (Message(..), parse)
import Ws.Methods.Handshake as Handshake
import Ws.Methods.StartScan as StartScan
import Ws.Notification exposing (Notification)
import Ws.Request
import Ws.Response exposing (Response)
import Ws.Types exposing (RequestData)


{-| Open a new websocket.
-}
open : String -> Update Model Msg
open ticket model =
    ( { model | websocketTicket = Just ticket }, Ports.websocketOpen <| getWebsocketUrl model.config )


{-| Sends a message.
-}
sendMessage : RequestData -> Update Model Msg
sendMessage request model =
    let
        id =
            model.websocketId

        newModel =
            addListener id request.listener model
    in
    ( { newModel | websocketId = id + 1 }
    , Ports.websocketOut <| Ws.Request.makeRequest id request.method request.params
    )


{-| Store a websocket listener in the given model.
-}
addListener : Int -> Maybe (Listener Model Msg) -> Model -> Model
addListener id maybeListener model =
    case maybeListener of
        Just listener ->
            Model.addListener id listener model

        Nothing ->
            model


{-| Handles a message arriving through the websocket.
-}
messageIn : String -> Update Model Msg
messageIn json =
    case parse json of
        Ok msg ->
            case msg of
                Message.Response r ->
                    responseIn r

                Message.Notification n ->
                    notificationIn n

        Err e ->
            \m -> ( { m | message = e }, Cmd.none )


responseIn : Response -> Update Model Msg
responseIn response model =
    case Model.getListener response.id model of
        Just listener ->
            listener response model

        Nothing ->
            ( model, Cmd.none )


notificationIn : Notification -> Update Model Msg
notificationIn notification model =
    case Model.getNotificationListener notification.method model of
        Just listener ->
            listener notification model

        Nothing ->
            ( model, Cmd.none )
