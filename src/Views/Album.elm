module Views.Album exposing (view)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
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
                , div [] <|
                    List.map
                        (\album ->
                            div [ class "home__artist" ]
                                [ a [ href <| "/album/" ++ fromInt album.id ] [ text album.name ]
                                ]
                        )
                        artist.albums
                ]
