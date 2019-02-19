port module Main exposing (emptyModel, init, main, setStorage, subscriptions, update, updateWithStorage, view, viewInput)

import API.Authenticate
import API.Scan
import API.Ticket
import Browser
import Browser.Navigation as Nav exposing (Key)
import Config
import Debug
import Html exposing (Html, a, button, div, form, input, section, text)
import Html.Attributes exposing (class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import JSON.Authenticate
import JSON.Request
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode as Encode
import Model exposing (Model)
import Msg exposing (..)
import Pages.Home as Home
import Pages.Login as Login
import Time
import Url


main : Program (Maybe Model) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }


port setStorage : Model -> Cmd msg


port websocketOpen : String -> Cmd msg


port websocketOpened : (Bool -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Encode.Value -> Cmd msg


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ setStorage newModel, cmds ]
    )


init : Maybe Model -> Url.Url -> Key -> ( Model, Cmd Msg )
init maybeModel url navKey =
    ( Maybe.withDefault emptyModel maybeModel
    , Cmd.none
    )


emptyModel : Model
emptyModel =
    { username = ""
    , password = ""
    , message = ""
    , isLoggedIn = False
    , token = Nothing
    , websocketTicket = Nothing
    , isScanning = False
    , scanCount = Nothing
    , websocketInbox = []
    , websocketId = 1
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ websocketOpened WebsocketOpened, websocketIn WebsocketIn ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnUrlRequest _ ->
            ( model, Cmd.none )

        OnUrlChange _ ->
            ( model, Cmd.none )

        UsernameChanged name ->
            ( { model | username = name }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            ( model, API.Authenticate.authenticate model )

        LogOut ->
            ( { model
                | isLoggedIn = False
                , username = ""
                , password = ""
                , token = Nothing
              }
            , Cmd.none
            )

        GotAuthenticateResponse response ->
            case response of
                Ok r ->
                    ( { model
                        | message = ""
                        , isLoggedIn = True
                        , token = Just r.token
                      }
                    , API.Ticket.getTicket r.token
                    )

                Err _ ->
                    ( { model | message = "Error!" }, Cmd.none )

        GotScanStatusResponse response ->
            case response of
                Ok r ->
                    ( { model | isScanning = r.isScanning, scanCount = Just r.count }, Cmd.none )

                Err _ ->
                    ( { model | message = "Scan failed!" }, Cmd.none )

        GotTicketResponse response ->
            case response of
                Ok r ->
                    ( { model | websocketTicket = Just r }, websocketOpen Config.ws )

                Err _ ->
                    ( model, websocketOpen "noo" )

        ScannerTick newTime ->
            ( model, API.Scan.getStatus model )

        WebsocketIn message ->
            ( { model | websocketInbox = message :: model.websocketInbox }, Cmd.none )

        OpenWebsocket url ->
            ( model, websocketOpen url )

        StartScan ->
            sendMessage model (Just <| startScan True)

        WebsocketOpened _ ->
            sendMessage model (sendTicket model.websocketTicket)


sendMessage : Model -> Maybe ( String, Encode.Value ) -> ( Model, Cmd Msg )
sendMessage model data =
    case data of
        Nothing ->
            ( model, Cmd.none )

        Just ( method, params ) ->
            ( { model | websocketId = model.websocketId + 1 }
            , websocketOut <|
                JSON.Request.makeRequest model.websocketId method params
            )


sendTicket : Maybe String -> Maybe ( String, Encode.Value )
sendTicket ticket =
    case ticket of
        Nothing ->
            Nothing

        Just t ->
            Just ( "handshake", JSON.Request.makeHandshakeRequest t )

startScan : Bool -> ( String, Encode.Value )
startScan shouldUpdate =
    ( "startScan", JSON.Request.makeStartScanRequest shouldUpdate )



-- VIEWS


onClickNoBubble : msg -> Html.Attribute msg
onClickNoBubble message =
    Html.Events.custom "click" (Json.Decode.succeed { message = message, stopPropagation = True, preventDefault = True })


view : Model -> Browser.Document Msg
view model =
    { title = "Sound"
    , body =
        [ case model.isLoggedIn of
            False ->
                div [ class "login__wrap" ]
                    [ text model.message
                    , form [ class "login__container" ]
                        [ div [ class "login__logo " ] [ text "Sound." ]
                        , viewInput "username" "text" "Username" model.username UsernameChanged
                        , viewInput "password" "password" "Password" model.password PasswordChanged
                        , button [ onClickNoBubble SubmitLogin, class "login__submit" ] [ text "Login" ]
                        ]
                    ]

            True ->
                div []
                    [ text "Welcome"

                    {- , text ("Your token is: " ++ Maybe.withDefault "?" model.token) -}
                    , text ("Scanned: " ++ (Maybe.withDefault 0 model.scanCount |> String.fromInt))
                    , button [ onClick LogOut ] [ text "Log out" ]
                    , button [ onClick StartScan ] [ text "Start scan" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput n t p v toMsg =
    input [ name n, type_ t, placeholder p, value v, onInput toMsg, class "login__input" ] []
