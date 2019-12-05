module Views.Playlists exposing (view)

import Artist.Types exposing (getRawArtistId)
import Dict
import Entities.ArtistSummary exposing (ArtistSummaries)
import Entities.PlaylistSummary exposing (PlaylistSummaries)
import Html
import Html.Styled exposing (Html, a, button, div, input, label, span, text)
import Html.Styled.Attributes exposing (checked, class, href, type_)
import Html.Styled.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Model -> Html Msg
view model =
    div [ class "home__wrap" ]
        [ viewPlaylists model.playlists
        ]


viewPlaylists : PlaylistSummaries -> Html msg
viewPlaylists playlists =
    div [ class "home__artists" ]
        (List.map
            (\playlist -> div [ class "home__artist" ] [ a [ href <| "/playlist/" ++ fromInt playlist.id ] [ text playlist.name ] ])
            (Dict.values playlists)
        )
