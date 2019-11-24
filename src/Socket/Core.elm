module Socket.Core exposing
    ( messageIn
    , open
    , sendMessage
    , sendMessageWithId
    , sendQueuedMessage
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


{-| Sends a socket message. Returns the ID of the message.
-}
sendMessageWithId : RequestData Model.Model -> UpdateWithReturn Model.Model Msg MessageId
sendMessageWithId request model =
    let
        socket =
            getSocketModel model

        messageId =
            socket.websocketId

        incremented =
            setSocketModel model { socket | websocketId = increment messageId }
    in
    if (getSocketModel model).isOpen then
        sendMessageNowWithId messageId request incremented

    else
        queueMessageWithId messageId request incremented


{-| Sends a socket message (for a consumer who doesn't need the message ID).
-}
sendMessage : RequestData Model.Model -> Update Model.Model Msg
sendMessage request model =
    let
        ( result, _ ) =
            sendMessageWithId request model
    in
    result


{-| Sends a socket message. Returns the ID of the message.
-}
sendQueuedMessage :
    ( MessageId, RequestData Model.Model )
    -> Update Model.Model Msg
sendQueuedMessage ( messageId, request ) model =
    let
        cleaned =
            unqueueMessage messageId model

        socketOpen =
            (getSocketModel cleaned).isOpen

        ( response, _ ) =
            if socketOpen then
                sendMessageNowWithId messageId request cleaned

            else
                queueMessageWithId messageId request cleaned
    in
    response


{-| Removes the message with the given ID from the queue.
-}
unqueueMessage : MessageId -> Model.Model -> Model.Model
unqueueMessage messageId model =
    let
        rawMessageId =
            getRawMessageId messageId

        socket =
            getSocketModel model

        queue =
            List.filter
                (\( id, _ ) -> getRawMessageId id /= rawMessageId)
                socket.messageQueue
    in
    setSocketModel model { socket | messageQueue = queue }


{-| Adds the request to the socket queue for sending once the socket is open.
-}
queueMessageWithId :
    MessageId
    -> RequestData Model.Model
    -> UpdateWithReturn Model.Model Msg MessageId
queueMessageWithId messageId request model =
    let
        socket =
            getSocketModel model

        added =
            { socket
                | messageQueue =
                    socket.messageQueue ++ [ ( messageId, request ) ]
            }
    in
    ( ( setSocketModel model added, Cmd.none )
    , messageId
    )


{-| Sends a message immediately (assumes the socket is open).
-}
sendMessageNowWithId :
    MessageId
    -> RequestData Model.Model
    -> UpdateWithReturn Model.Model Msg MessageId
sendMessageNowWithId messageId request model =
    let
        socket =
            getSocketModel model

        added =
            case request.listener of
                Just listener ->
                    addListener messageId listener socket

                Nothing ->
                    socket

        message =
            Socket.Request.makeRequest messageId request.method request.params
    in
    ( ( setSocketModel model added
      , Ports.websocketOut message
      )
    , messageId
    )


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
