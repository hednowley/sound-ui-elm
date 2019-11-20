module Views.Playlist exposing (view)

import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import Playlist.Select exposing (getPlaylist, getPlaylistSongs)
import Views.Song


view : Int -> Model -> Html.Html Msg
view playlistId model =
    case getPlaylist playlistId model of
        Absent ->
            div [] [ text "No playlist" ]

        Loading _ ->
            div [] [ text "Loading playlist" ]

        Loaded playlist ->
            div []
                [ div []
                    [ div [] [ text playlist.name ]
                    , button [ onClick <| AudioMsg (PlayPlaylist playlistId) ] [ text "Play playlist" ]
                    ]
                , div [] <|
                    List.map (Views.Song.view model) (getPlaylistSongs playlist)
                ]
