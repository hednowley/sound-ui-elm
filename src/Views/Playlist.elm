module Views.Playlist exposing (view)

import Album.Select exposing (getAlbum, getAlbumSongs)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Views.Song


view : Model -> Html.Html Msg
view model =
    case model.currentPlaylist of
        Absent ->
            div [] [ text "No playlist" ]

        Loading ->
            div [] [ text "Loading playlist" ]

        Loaded playlist ->
            div []
                [ div []
                    [ div [] [ text playlist.name ]
                    , button [ onClick <| AudioMsg (PlayPlaylist playlist) ] [ text "Play playlist" ]
                    ]
                , div [] <|
                    List.map (Views.Song.view model) (getAlbumSongs playlist)
                ]
