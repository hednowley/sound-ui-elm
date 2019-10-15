module Views.Player exposing (view)

import Array
import Html exposing (button, div, text)
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
    div []
        [ case model.playing of
            Just _ ->
                button [ onClick (AudioMsg Pause) ] [ text "Pause" ]

            Nothing ->
                text ""
        , case model.audioTime of
            Just time ->
                div [] [ text <| fromFloat time ]

            Nothing ->
                text ""
        , case model.audioTime of
            Just time ->
                button [ onClick <| AudioMsg (SetTime <| time + 15) ] [ text "+15" ]

            Nothing ->
                text ""
        ]
