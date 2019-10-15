module Views.Root exposing (view)

import Array
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Routing exposing (Route(..))
import Views.Album
import Views.Artist
import Views.Home
import Views.PlaylistItem
import Views.Song


view : Model -> Html.Html Msg
view model =
    div []
        [ case model.route of
            Nothing ->
                Views.Home.view model

            Just (Artist id) ->
                Views.Artist.view id model

            Just (Album id) ->
                Views.Album.view id model
        , div []
            [ div [] [ text "Playlist" ]
            , div [] (Array.indexedMap (Views.PlaylistItem.view model) model.playlist |> Array.toList)
            ]
        , div []
            [ case model.playing of
                Just _ ->
                    button [ onClick (AudioMsg Pause) ] [ text "Pause" ]

                Nothing ->
                    text ""
            ]
        ]
