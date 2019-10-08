module Ws.Core exposing
    ( addListener
    , messageIn
    , sendMessage
    )

import Config
import Dict
import Http
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports
import Ws.Listener
import Ws.Methods.Handshake as Handshake
import Ws.Methods.StartScan as StartScan
import Ws.Notification
import Ws.Request
import Ws.Response
import Ws.Types exposing (RequestData)


{-| Sends a message.
-}
sendMessage : Model -> RequestData -> ( Model, Cmd Msg )
sendMessage model request =
    let
        id =
            model.websocketId

        newModel =
            addListener id request.listener model
    in
    ( { newModel
        | websocketId = id + 1
      }
    , Ports.websocketOut <|
        Ws.Request.makeRequest id request.method request.params
    )


{-| Store a websocket listener in the given model.
-}
addListener : Int -> Maybe (Ws.Listener.Listener Model) -> Model -> Model
addListener id maybeListener model =
    case maybeListener of
        Just listener ->
            Model.addListener id listener model

        Nothing ->
            model


{-| Handles a message arriving through the websocket.
-}
messageIn : String -> Model -> Model
messageIn message =
    case Ws.Response.decode message of
        -- Message is a response
        Just response ->
            responseIn response

        -- Message might be a notification
        Nothing ->
            case Ws.Notification.decode message of
                Just notification ->
                    notificationIn notification

                Nothing ->
                    \m -> m


responseIn : Ws.Response.Response -> Model -> Model
responseIn response model =
    case Model.getListener response.id model of
        Just listener ->
            listener response.body model

        Nothing ->
            model


notificationIn : Ws.Notification.Notification -> Model -> Model
notificationIn notification model =
    case Model.getNotificationListener notification.method model of
        Just listener ->
            listener notification model

        Nothing ->
            model
