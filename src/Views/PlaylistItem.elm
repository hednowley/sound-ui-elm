module Views.PlaylistItem exposing (view)

import Dict
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))


view : Model -> Int -> Int -> Html.Html Msg
view model index songId =
    case Dict.get songId model.songs of
        Just song ->
            div [ class "playlist__item" ]
                [ button [ onClick <| AudioMsg (PlayItem index) ] [ text "Play" ]
                , div [] [ text song.name ]
                ]

        Nothing ->
            div [] [ text "Nothing" ]
