port module Main exposing (init, main, subscriptions)

import Browser exposing (UrlRequest)
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


type alias Model =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : String
    }


emptyModel : Model
emptyModel =
    { username = ""
    , password = ""
    , message = ""
    , isLoggedIn = False
    , token = ""
    }


type Msg
    = OnUrlChange Url
    | OnUrlRequest UrlRequest
    | UsernameChanged String
    | PasswordChanged String
    | Submit
    | LogOut
    | GotResponse (Result Http.Error ApiResponse)


type alias ApiResponse =
    { status : String, token : String }


userEncoder : Model -> Encode.Value
userEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


responseDecoder : Decoder ApiResponse
responseDecoder =
    map2 ApiResponse
        (field "status" string)
        (field "data" (field "token" string))


authenticate : Model -> Cmd Msg
authenticate model =
    Http.post
        { body = (Http.jsonBody << userEncoder) model
        , url = "http://hednowley.synology.me:171/api/authenticate"
        , expect = Http.expectJson GotResponse responseDecoder
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

        Submit ->
            ( model, authenticate model )

        LogOut ->
            ( { model
                | isLoggedIn = False
                , username = ""
                , password = ""
              }
            , Cmd.none
            )

        GotResponse response ->
            case response of
                Ok r ->
                    ( { model
                        | message = ""
                        , isLoggedIn = True
                        , token = r.token
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | message = "Error!" }, Cmd.none )



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
                    , button [ onClick Submit ] [ text "Login" ]
                    ]

            True ->
                div []
                    [ text "Welcome"
                    , text ("Your token is: " ++ model.token)
                    , button [ onClick LogOut ] [ text "Log out" ]
                    ]
        ]
    }


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []
