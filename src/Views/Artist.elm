module Views.Artist exposing (view)

import Artist.Select exposing (getArtist)
import Artist.Types exposing (ArtistId)
import Audio.AudioMsg exposing (AudioMsg(..))
import Html exposing (div, text)
import Html.Attributes exposing (class)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Views.MiniAlbum


view : ArtistId -> Model -> Html.Html Msg
view artistId model =
    case getArtist artistId model of
        Absent ->
            div [] [ text "No artist" ]

        Loading _ ->
            div [] [ text "Loading artist" ]

        Loaded artist ->
            div []
                [ div [] [ text artist.name ]
                , div [ class "artist__albums" ] <|
                    List.map
                        Views.MiniAlbum.view
                        artist.albums
                ]
