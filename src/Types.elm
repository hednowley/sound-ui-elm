module Types exposing (Update)

import Model exposing (Model)
import Msg exposing (Msg)


type alias Update =
    Msg -> Model -> ( Model, Cmd Msg )
