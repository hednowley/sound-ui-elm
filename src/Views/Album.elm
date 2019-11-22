module Views.Album exposing (view)

import Album.Select exposing (getAlbum, getAlbumArt, getAlbumSongs)
import Audio.AudioMsg exposing (AudioMsg(..))
import Html exposing (button, div, img, text)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Views.Song


view : Int -> Model -> Html.Html Msg
view id model =
    case getAlbum id model of
        Absent ->
            div [] [ text "No album" ]

        Loading _ ->
            div [] [ text "Loading album" ]

        Loaded album ->
            div []
                [ div []
                    [ div [] [ text album.name ]
                    , img [ class "album__art", src <| getAlbumArt album.artId ] []
                    , button [ onClick <| AudioMsg (PlayAlbum id) ] [ text "Play album" ]
                    ]
                , div [] <|
                    List.map (Views.Song.view model) (getAlbumSongs album)
                ]
