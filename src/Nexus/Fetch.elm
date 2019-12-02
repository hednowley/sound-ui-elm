module Nexus.Fetch exposing (fetch)

import Dict exposing (Dict)
import Json.Decode exposing (Decoder)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Socket.Actions exposing (addListenerExternal)
import Socket.Core exposing (sendMessageWithId)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.RequestData exposing (RequestData)
import Types exposing (Update)


type alias MaybeCallback a =
    Maybe (a -> Update Model Msg)


type alias MakeMessage id =
    id -> Listener Model Msg -> RequestData Model


type alias GetRepo obj =
    Model -> Dict Int (Loadable obj)


type alias SetRepo obj =
    Dict Int (Loadable obj) -> Model -> Model


type alias OnFetch obj =
    obj -> Model -> Model


fetch :
    (id -> Int)
    -> MakeMessage id
    -> Decoder dto
    -> (dto -> obj)
    -> GetRepo obj
    -> SetRepo obj
    -> OnFetch obj
    -> MaybeCallback obj
    -> id
    -> Update Model Msg
fetch extractId makeMessage decoder convert getDict setDict onFetch maybeCallback id model =
    let
        extractedId =
            extractId id

        stored =
            Dict.get extractedId (getDict model)
    in
    case Maybe.withDefault Absent stored of
        {- This thing has never been fetched. -}
        Absent ->
            let
                ( ( sentModel, cmd ), messageId ) =
                    sendMessageWithId
                        (makeMessage id
                            (onResponse
                                getDict
                                setDict
                                convert
                                decoder
                                onFetch
                                maybeCallback
                                extractedId
                            )
                        )
                        False
                        model

                insertedDict =
                    Dict.insert extractedId (Loading messageId) (getDict sentModel)
            in
            ( setDict insertedDict sentModel, cmd )

        {- There is already an in-flight fetch for this thing. -}
        Loading requestId ->
            case maybeCallback of
                Just callback ->
                    ( addListenerExternal
                        requestId
                        (onResponse
                            getDict
                            setDict
                            convert
                            decoder
                            onFetch
                            (Just callback)
                            extractedId
                        )
                        model
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        {- This thing has already been fetched -}
        Loaded playlist ->
            case maybeCallback of
                Just callback ->
                    callback playlist model

                Nothing ->
                    ( model, Cmd.none )


onResponse :
    GetRepo obj
    -> SetRepo obj
    -> (dto -> obj)
    -> Decoder dto
    -> OnFetch obj
    -> MaybeCallback obj
    -> Int
    -> Listener Model Msg
onResponse getRepo setRepo convert decoder onFetch maybeCallback id =
    makeIrresponsibleListener
        Nothing
        decoder
        (onSuccess getRepo setRepo convert onFetch maybeCallback id)


onSuccess :
    GetRepo obj
    -> SetRepo obj
    -> (dto -> obj)
    -> OnFetch obj
    -> MaybeCallback obj
    -> Int
    -> dto
    -> Update Model Msg
onSuccess getRepo setRepo convert onFetch maybeCallback id dto model =
    let
        thing =
            convert dto

        insertedDict =
            Dict.insert id (Loaded thing) (getRepo model)

        inserted =
            setRepo insertedDict model

        newModel =
            onFetch thing inserted
    in
    case maybeCallback of
        Nothing ->
            ( newModel, Cmd.none )

        Just callback ->
            callback thing newModel
