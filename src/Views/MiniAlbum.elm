module Views.MiniAlbum exposing (view)

import Album.Select exposing (getAlbumArt)
import Album.Types exposing (AlbumId, getRawAlbumId)
import Audio.AudioMsg exposing (AudioMsg(..))
import Entities.AlbumSummary exposing (AlbumSummary)
import Html exposing (a, button, div, img, text)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : AlbumSummary -> Html.Html Msg
view album =
    div [ class "home__artist" ]
        [ div []
            [ img [ class "artist__album--art", src <| getAlbumArt album.artId ] []
            , a [ href <| "/album/" ++ fromInt (getRawAlbumId album.id) ] [ text album.name ]
            , button [ onClick <| AudioMsg (PlayAlbum album.id) ] [ text "Play" ]
            ]
        ]
