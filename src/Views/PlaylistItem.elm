module Views.PlaylistItem exposing (view)

import Audio
import Dict
import Entities.SongSummary exposing (SongSummary)
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
            div [ class "home__artist" ]
                [ div [] [ text song.name ]
                , button [ onClick <| AudioMsg (PlayItem index) ] [ text "Play" ]
                ]

        Nothing ->
            div [] [ text "Nothing" ]
