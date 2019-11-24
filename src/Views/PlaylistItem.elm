module Views.PlaylistItem exposing (view)

import Audio.AudioMsg exposing (AudioMsg(..))
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Song.Select exposing (getSong)
import Song.Types exposing (SongId)


view : Model -> Int -> SongId -> Html.Html Msg
view model index songId =
    case getSong model songId of
        Just song ->
            div [ class "playlist__item" ]
                [ button [ onClick <| AudioMsg (PlayItem index) ] [ text "Play" ]
                , div [] [ text song.name ]
                ]

        Nothing ->
            div [] [ text "Nothing" ]
