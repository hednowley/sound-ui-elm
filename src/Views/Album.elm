module Views.Album exposing (view)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Int -> Model -> Html.Html Msg
view id model =
    case model.album of
        Absent ->
            div [] [ text "No album" ]

        Loading ->
            div [] [ text "Loading album" ]

        Loaded album ->
            div []
                [ div [] [ text album.name ]
                , div [] <|
                    List.map
                        (\song ->
                            div [ class "home__artist" ]
                                [ a [ href <| "/song/" ++ fromInt song.id ] [ text song.name ]
                                ]
                        )
                        album.songs
                ]
