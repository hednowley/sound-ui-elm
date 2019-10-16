module Views.Player exposing (view)

import Array
import Audio.Select exposing (getCurrentSongState)
import AudioState exposing (State(..))
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Routing exposing (Route(..))
import String exposing (fromFloat)
import Views.Album
import Views.Artist
import Views.Home
import Views.PlaylistItem
import Views.Song


view : Model -> Html.Html Msg
view model =
    div [ class "player__wrap" ]
        [ case getCurrentSongState model of
            Just (AudioState.Playing time) ->
                button [ onClick (AudioMsg Pause) ] [ text "Pause" ]

            _ ->
                text ""
        , case getCurrentSongState model of
            Just (AudioState.Playing time) ->
                div [] [ text <| fromFloat time ]

            _ ->
                text ""
        , case getCurrentSongState model of
            Just (AudioState.Playing time) ->
                button [ onClick <| AudioMsg (SetTime <| time + 15) ] [ text "+15" ]

            _ ->
                text ""
        ]
