module Views.Player exposing (view)

import Audio.Select exposing (getCurrentSongState)
import AudioState exposing (State(..))
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Routing exposing (Route(..))
import String exposing (fromFloat)


view : Model -> Html.Html Msg
view model =
    div [ class "player__wrap" ]
        [ case getCurrentSongState model of
            Just state ->
                div []
                    [ backButton state, playButton state, forwardButton state, nextButton state, slider state ]

            _ ->
                text ""
        ]


backButton : State -> Html.Html Msg
backButton state =
    case state of
        AudioState.Playing time ->
            button [ onClick <| AudioMsg (SetTime <| time - 15) ] [ text "-15" ]

        AudioState.Paused time ->
            button [ onClick <| AudioMsg (SetTime <| time - 15) ] [ text "-15" ]

        _ ->
            text ""


playButton : State -> Html.Html Msg
playButton state =
    case state of
        AudioState.Playing _ ->
            button [ onClick <| AudioMsg Pause ] [ text "Pause" ]

        AudioState.Paused _ ->
            button [ onClick <| AudioMsg Resume ] [ text "Play" ]

        _ ->
            text ""


forwardButton : State -> Html.Html Msg
forwardButton state =
    case state of
        AudioState.Playing time ->
            button [ onClick <| AudioMsg (SetTime <| time + 15) ] [ text "+15" ]

        AudioState.Paused time ->
            button [ onClick <| AudioMsg (SetTime <| time + 15) ] [ text "+15" ]

        _ ->
            text ""


nextButton : State -> Html.Html Msg
nextButton state =
    case state of
        AudioState.Playing _ ->
            button [ onClick <| AudioMsg Next ] [ text ">|" ]

        AudioState.Paused _ ->
            button [ onClick <| AudioMsg Next ] [ text ">|" ]

        _ ->
            text ""


slider : State -> Html.Html Msg
slider state =
    case state of
        AudioState.Playing time ->
            div [] [ text <| fromFloat time ]

        AudioState.Paused time ->
            div [] [ text <| fromFloat time ]

        _ ->
            text ""
