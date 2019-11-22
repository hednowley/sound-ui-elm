module Views.Artist exposing (view)

import Album.Select exposing (getAlbumArt)
import Audio.AudioMsg exposing (AudioMsg(..))
import Html exposing (a, button, div, img, text)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Int -> Model -> Html.Html Msg
view id model =
    case model.artist of
        Absent ->
            div [] [ text "No artist" ]

        Loading _ ->
            div [] [ text "Loading artist" ]

        Loaded artist ->
            div []
                [ div [] [ text artist.name ]
                , div [ class "artist__albums" ] <|
                    List.map
                        (\album ->
                            div [ class "home__artist" ]
                                [ div []
                                    [ img [ class "artist__album--art", src <| getAlbumArt album.artId ] []
                                    , a [ href <| "/album/" ++ fromInt album.id ] [ text album.name ]
                                    , button [ onClick <| AudioMsg (PlayAlbum album.id) ] [ text "Play" ]
                                    ]
                                ]
                        )
                        artist.albums
                ]
