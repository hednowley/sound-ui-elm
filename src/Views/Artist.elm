module Views.Artist exposing (view)

import Html exposing (div, text)
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Int -> Model -> Html.Html Msg
view id _ =
    div [] [ text <| fromInt id ]
