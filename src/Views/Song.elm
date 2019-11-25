module Views.Song exposing (view)

import Audio.AudioMsg exposing (AudioMsg(..))
import Entities.SongSummary exposing (SongSummary)
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Player.Msg exposing (PlayerMsg(..))
import String exposing (fromInt)


view : Model -> SongSummary -> Html.Html Msg
view model song =
    div [ class "album__song" ]
        [ button [ onClick <| PlayerMsg (Play song.id) ] [ text "Play" ]
        , button [ onClick <| PlayerMsg (Queue song.id) ] [ text "Queue" ]
        , div [] [ text <| fromInt song.track ]
        , div [] [ text song.name ]
        ]
