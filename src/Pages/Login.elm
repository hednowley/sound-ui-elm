module Pages.Login exposing (Msg(..), Model, view, update, subscriptions, init)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode as Encode

-- MODEL


type alias Model =
    { username : String, password : String, message : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" "", Cmd.none )



-- UPDATE


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


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | Submit
    | GotResponse (Result Http.Error ApiResponse)
    | LoggedIn


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UsernameChanged name ->
            ( { model | username = name }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model, authenticate model )

        GotResponse response ->
            case response of
                Ok r ->
                    ( { model | message = "Your token is: " ++ r.token }
                    , Cmd.map (always LoggedIn) Cmd.none )

                Err _ ->
                    ( { model | message = "Error!" }, Cmd.none )

        LoggedIn -> ( model, Cmd.none )

              



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text model.message
        , viewInput "text" "Name" model.username UsernameChanged
        , viewInput "password" "PasswordChanged" model.password PasswordChanged
        , button [ onClick Submit ] [ text "Login" ]
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []
