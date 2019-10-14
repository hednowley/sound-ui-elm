module Views.Song exposing (view)

import Entities.SongSummary exposing (SongSummary)
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))


view : SongSummary -> Html.Html Msg
view song =
    div [ class "home__artist" ]
        [ div [] [ text song.name ]
        , button [ onClick <| AudioMsg (Play song.id) ] [ text "Play" ]
        , button [ onClick <| AudioMsg (Queue song.id) ] [ text "Queue" ]
        ]
