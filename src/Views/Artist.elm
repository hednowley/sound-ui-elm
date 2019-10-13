module Views.Artist exposing (view)

import Html exposing (div, text)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Int -> Model -> Html.Html Msg
view id model =
    case model.artist of
        Absent ->
            div [] [ text "No artist" ]

        Loading ->
            div [] [ text "Loading artist" ]

        Loaded artist ->
            div [] [ text artist.name ]
