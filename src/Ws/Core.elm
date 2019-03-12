module Ws.Core exposing (addListener, sendMessage, update)

import Dict
import Http
import Json.Encode
import Model exposing (Model)
import Ports
import Ws.Listener
import Ws.Methods.Handshake as Handshake
import Ws.Methods.StartScan
import Ws.Msg as Msg exposing (Msg(..))
import Ws.Request
import Ws.Response
import Ws.Types exposing (RequestData)


{-| Sends a message.
-}
sendMessage : Model -> RequestData -> ( Model, Cmd Msg )
sendMessage model data =
    let
        newModel =
            addListener model data.listener
    in
    ( { newModel
        | websocketId = newModel.websocketId + 1
      }
    , Ports.websocketOut <|
        Ws.Request.makeRequest newModel.websocketId data.method data.params
    )


addListener : Model -> Maybe (Ws.Listener.Listener Model) -> Model
addListener model maybeListener =
    case maybeListener of
        Just listener ->
            let
                (Model.Listeners listeners) =
                    model.websocketListeners
            in
            { model | websocketListeners = Model.Listeners <| Dict.insert model.websocketId listener listeners }

        Nothing ->
            model


messageIn : String -> Model -> Model
messageIn message model =
    let
        result = Ws.Response.decode message
    in
    case result of
        Ok response ->
            responseIn response model

        Err error ->
            model


responseIn : Ws.Response.Response -> Model -> Model
responseIn response model =
    let
        (Model.Listeners listeners) =
            model.websocketListeners

        maybeListener =
            Dict.get response.id listeners
    in
    case maybeListener of
        Just listener ->
            listener response.body model

        Nothing ->
            model


startScan : Bool -> ( String, Json.Encode.Value )
startScan shouldUpdate =
    ( "startScan", Ws.Methods.StartScan.makeRequest shouldUpdate )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebsocketOpened _ ->
            case model.websocketTicket of
                Just ticket ->
                    sendMessage model (Handshake.prepareRequest ticket)

                Nothing ->
                    ( model, Cmd.none )

        WebsocketIn message ->
            ( messageIn message model, Cmd.none )

        OpenWebsocket url ->
            ( model, Ports.websocketOpen url )

        StartScan ->
            ( model, Cmd.none )
