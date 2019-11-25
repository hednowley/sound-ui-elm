module Views.Player exposing (view)

import Audio.AudioMsg exposing (AudioMsg(..))
import AudioState exposing (State(..))
import Html exposing (button, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Player.Msg exposing (PlayerMsg(..))
import Player.Select exposing (getCurrentSongId, getCurrentSongState)
import Routing exposing (Route(..))
import Song.Select exposing (getSong)
import String exposing (fromFloat)


view : Model -> Html.Html Msg
view model =
    div [ class "player__wrap" ] <|
        case getCurrentSongState model of
            Just state ->
                [ div [ class "player__controls" ]
                    [ prevButton state
                    , backButton state
                    , playButton state
                    , forwardButton state
                    , nextButton state
                    , shuffleButton
                    , songDetails model
                    ]
                , slider state
                ]

            _ ->
                []


backButton : State -> Html.Html Msg
backButton state =
    case state of
        AudioState.Playing { time } ->
            button [ onClick <| AudioMsg (SetTime <| time - 15) ] [ text "-15" ]

        _ ->
            text ""


playButton : State -> Html.Html Msg
playButton state =
    case state of
        AudioState.Playing { paused } ->
            if paused then
                button [ onClick <| PlayerMsg Resume ] [ text "Play" ]

            else
                button [ onClick <| PlayerMsg Pause ] [ text "Pause" ]

        _ ->
            text ""


forwardButton : State -> Html.Html Msg
forwardButton state =
    case state of
        AudioState.Playing { time } ->
            button [ onClick <| AudioMsg (SetTime <| time + 15) ] [ text "+15" ]

        _ ->
            text ""


nextButton : State -> Html.Html Msg
nextButton state =
    case state of
        AudioState.Playing _ ->
            button [ onClick <| PlayerMsg Next ] [ text ">|" ]

        _ ->
            text ""


prevButton : State -> Html.Html Msg
prevButton state =
    case state of
        AudioState.Playing _ ->
            button [ onClick <| PlayerMsg Prev ] [ text "|<" ]

        _ ->
            text ""


shuffleButton : Html.Html Msg
shuffleButton =
    button [ onClick <| PlayerMsg Shuffle ] [ text "Shuffle" ]


songDetails : Model -> Html.Html Msg
songDetails model =
    let
        title =
            case
                getCurrentSongId model |> Maybe.andThen (getSong model)
            of
                Just song ->
                    song.name

                Nothing ->
                    ""
    in
    div [] [ text title ]


slider : State -> Html.Html Msg
slider state =
    div [ class "player__slider--wrap" ]
        [ case state of
            AudioState.Playing { time, duration } ->
                case duration of
                    Just d ->
                        div [ class "player__slider--elapsed", style "width" (fromFloat (100 * time / d) ++ "%") ] []

                    Nothing ->
                        text ""

            _ ->
                text ""
        ]
