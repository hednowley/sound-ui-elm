module Views.Artists exposing (view)

import Album.Types exposing (AlbumId, getRawAlbumId)
import Artist.Types exposing (getRawArtistId)
import Dict
import Entities.AlbumSummary exposing (AlbumSummaries)
import Entities.ArtistSummary exposing (ArtistSummaries)
import Html exposing (Html, a, button, div, input, label, span, text)
import Html.Attributes exposing (checked, class, href, type_)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Model -> Html.Html Msg
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
                    [ a [ href <| "/album/" ++ fromInt (getRawArtistId album.id) ] [ text album.name ] ]
            )
            (Dict.values albums)
        )
