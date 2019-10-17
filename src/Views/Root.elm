module Views.Root exposing (view)

import Array
import Html exposing (div, text)
import Html.Attributes exposing (class)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Routing exposing (Route(..))
import Views.Album
import Views.Artist
import Views.Home
import Views.Player
import Views.PlaylistItem


view : Model -> Html.Html Msg
view model =
    div [ class "app__wrap" ]
        [ div [ class "app__main" ]
            [ case model.route of
                Nothing ->
                    Views.Home.view model

                Just (Artist id) ->
                    Views.Artist.view id model

                Just (Album id) ->
                    Views.Album.view id model
            ]
        , div [ class "app__playlist" ]
            [ div [] [ text "Playlist" ]
            , div [ class "playlist__items" ] (Array.indexedMap (Views.PlaylistItem.view model) model.playlist |> Array.toList)
            ]
        , div [ class "app__player" ] [ Views.Player.view model ]
        ]
