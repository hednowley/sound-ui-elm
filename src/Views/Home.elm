module Views.Home exposing (view)

import Dict
import Entities.ArtistSummary exposing (ArtistSummaries)
import Entities.PlaylistSummary exposing (PlaylistSummaries)
import Html exposing (Html, a, button, div, input, label, span, text)
import Html.Attributes exposing (checked, class, href, type_)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Model -> Html.Html Msg
view model =
    div [ class "home__wrap" ]
        [ span [] [ text <| "Scanned: " ++ String.fromInt model.scanCount ]
        , button [ onClick LogOut ] [ text "Log out" ]
        , checkboxInput "Update?" model.scanShouldUpdate ToggleScanUpdate
        , checkboxInput "Delete?" model.scanShouldDelete ToggleScanDelete
        , button [ onClick StartScan ] [ text "Start scan" ]
        , div [] [ text "Artists" ]
        , viewArtists model.artists
        , div [] [ text "Playlists" ]
        , viewPlaylists model.playlists
        ]


checkboxInput : String -> Bool -> msg -> Html msg
checkboxInput name isChecked msg =
    label [] [ input [ checked isChecked, type_ "checkbox", onClick msg ] [], text name ]


viewArtists : ArtistSummaries -> Html msg
viewArtists artists =
    div [ class "home__artists" ]
        (List.map
            (\artist -> div [ class "home__artist" ] [ a [ href <| "/artist/" ++ fromInt artist.id ] [ text artist.name ] ])
            (Dict.values artists)
        )


viewPlaylists : PlaylistSummaries -> Html msg
viewPlaylists playlists =
    div [ class "home__artists" ]
        (List.map
            (\playlist -> div [ class "home__artist" ] [ a [ href <| "/playlist/" ++ fromInt playlist.id ] [ text playlist.name ] ])
            (Dict.values playlists)
        )
