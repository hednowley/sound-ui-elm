module Views.Sidebar exposing (view)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Model exposing (Model)
import Msg exposing (Msg(..))


view : Model -> Html.Html Msg
view model =
    div
        []
        [ div
            [ class "app__header" ]
            [ a [ href "/" ] [ text "Home" ] ]
        , div
            [ class "app__header" ]
            [ a [ href "/artists" ] [ text "Artists" ] ]
        , div
            [ class "app__header" ]
            [ a [ href "/albums" ] [ text "Albums" ] ]
        , div
            [ class "app__header" ]
            [ a [ href "/playlists" ] [ text "Playlists" ] ]
        ]
