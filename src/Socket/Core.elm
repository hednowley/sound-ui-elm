module Socket.Core exposing
    ( messageIn
    , open
    , sendMessage
    , sendMessageWithId
    )

import Model exposing (getSocketModel, setSocketModel)
import Msg exposing (Msg(..))
import Ports
import Routing exposing (getWebsocketUrl)
import Socket.Actions exposing (addListener)
import Socket.Listener exposing (Listener)
import Socket.Message as Message exposing (Message(..), parse)
import Socket.Model
import Socket.Notification exposing (Notification)
import Socket.Request
import Socket.RequestData exposing (RequestData)
import Socket.Response exposing (Response)
import Socket.Select exposing (getListener, getNotificationListener)
import Socket.Types exposing (MessageId(..), getRawMessageId)
import Types exposing (Update, UpdateWithReturn)


increment : MessageId -> MessageId
increment id =
    MessageId <| getRawMessageId id + 1


{-| Open a new websocket.
-}
open : String -> Update Model.Model Msg
open ticket model =
    let
        socket =
            getSocketModel model
    in
    ( setSocketModel model { socket | ticket = Just ticket }
    , Ports.websocketOpen <| getWebsocketUrl model.url
    )


{-| Sends a message.
-}
sendMessageWithId : RequestData Model.Model -> UpdateWithReturn Model.Model Msg MessageId
sendMessageWithId request model =
    let
        socket =
            getSocketModel model

        messageId =
            socket.websocketId

        added =
            case request.listener of
                Just listener ->
                    addListener messageId listener socket

                Nothing ->
                    socket
    in
    ( ( setSocketModel model { added | websocketId = increment messageId }
      , Ports.websocketOut <| Socket.Request.makeRequest messageId request.method request.params
      )
    , messageId
    )


{-| Sends a message.
-}
sendMessage : RequestData Model.Model -> Update Model.Model Msg
sendMessage request model =
    let
        socket =
            getSocketModel model
    in
    let
        ( result, _ ) =
            sendMessageWithId request model
    in
    result


{-| Handles a message arriving through the websocket.
-}
messageIn : String -> Update Model.Model Msg
messageIn json model =
    let
        socket =
            getSocketModel model
    in
    case parse json of
        Ok msg ->
            case msg of
                Message.Response r ->
                    responseIn r model

                Message.Notification n ->
                    notificationIn n model

        Err e ->
            ( model, Cmd.none )


responseIn : Response -> Update Model.Model Msg
responseIn response model =
    let
        socket =
            getSocketModel model
    in
    case getListener response.id socket of
        Just listener ->
            listener response model

        Nothing ->
            ( model, Cmd.none )


notificationIn : Notification -> Update Model.Model Msg
notificationIn notification model =
    let
        socket =
            getSocketModel model
    in
    case getNotificationListener notification.method socket of
        Just listener ->
            listener notification model

        Nothing ->
            ( model, Cmd.none )
