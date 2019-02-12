port module Main exposing (..)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, a, button, div, input, section, text)
import Html.Attributes exposing (class, href, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode as Encode
import Pages.Home as Home
import Pages.Login as Login
import Url exposing (Url)
import JSON.Authenticate
import API.Authenticate
import Model exposing (Model)
import Msg exposing (..)
import API.Authenticate
import API.Scan


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


init : Maybe Model -> Url -> Key -> ( Model, Cmd Msg )
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
    }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


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

        StartScan -> 
            ( model, API.Scan.startScan model )


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
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | message = "Error!" }, Cmd.none )

        GotStartScanResponse response ->
            case response of
                Ok r ->
                    ( model , Cmd.none )

                Err _ ->
                    ( { model | message = "Scan failed!" }, Cmd.none )



-- VIEWS


view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ case model.isLoggedIn of
            False ->
                div []
                    [ text model.message
                    , viewInput "text" "Name" model.username UsernameChanged
                    , viewInput "password" "PasswordChanged" model.password PasswordChanged
                    , button [ onClick SubmitLogin ] [ text "Login" ]
                    ]

            True ->
                div []
                    [ text "Welcome"
                    , text ("Your token is: " ++ (Maybe.withDefault "?" model.token))
                    , button [ onClick LogOut ] [ text "Log out" ]
                    , button [ onClick StartScan ] [ text "Start scan" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []
