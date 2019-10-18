module Views.Album exposing (view)

import Album.Select exposing (getAlbum, getAlbumSongs)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Views.Song


view : Int -> Model -> Html.Html Msg
view id model =
    case getAlbum id model of
        Absent ->
            div [] [ text "No album" ]

        Loading ->
            div [] [ text "Loading album" ]

        Loaded album ->
            div []
                [ div []
                    [ div [] [ text album.name ]
                    , button [ onClick <| AudioMsg (PlayAlbum id) ] [ text "Play album" ]
                    ]
                , div [] <|
                    List.map (Views.Song.view model) (getAlbumSongs album)
                ]
