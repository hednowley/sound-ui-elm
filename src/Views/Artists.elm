module Views.Artists exposing (view)

import Album.Types exposing (AlbumId, getRawAlbumId)
import Artist.Types exposing (getRawArtistId)
import Dict
import Entities.AlbumSummary exposing (AlbumSummaries)
import Entities.ArtistSummary exposing (ArtistSummaries)
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
        [ viewAlbums model.artists
        ]


viewAlbums : ArtistSummaries -> Html msg
viewAlbums albums =
    div [ class "home__artists" ]
        (List.map
            (\album ->
                div
                    [ class "home__artist" ]
                    [ a [ href <| "/artist/" ++ fromInt (getRawArtistId album.id) ] [ text album.name ] ]
            )
            (Dict.values albums)
        )
