module Views.Artist exposing (view)

import Html exposing (a, button, div, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (AudioMsg(..), Msg(..))
import String exposing (fromInt)


view : Int -> Model -> Html.Html Msg
view id model =
    case model.artist of
        Absent ->
            div [] [ text "No artist" ]

        Loading ->
            div [] [ text "Loading artist" ]

        Loaded artist ->
            div []
                [ div [] [ text artist.name ]
                , div [ class "artist__albums" ] <|
                    List.map
                        (\album ->
                            div [ class "home__artist" ]
                                [ div []
                                    [ a [ href <| "/album/" ++ fromInt album.id ] [ text album.name ]
                                    , button [ onClick <| AudioMsg (PlayAlbum album.id) ] [ text "Play" ]
                                    ]
                                ]
                        )
                        artist.albums
                ]
