module Pages.Home exposing (Model, Msg, defaultModel, init, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode as Encode



-- MODEL


type alias Model =
    {}


defaultModel =
    { 
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( defaultModel, Cmd.none )



-- UPDATE


type alias ApiResponse =
    { status : String, token : String }


type Msg = Logout


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Logout ->
            ( model , Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text "Welcome!" ]