module Routing exposing (Route(..), getWebsocketUrl, parseUrl)

import Album.Types exposing (AlbumId(..))
import Artist.Types exposing (ArtistId(..))
import String exposing (fromInt)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s)


getWebsocketUrl : Url -> String
getWebsocketUrl url =
    let
        port_ =
            case url.port_ of
                Just p ->
                    ":" ++ fromInt p

                Nothing ->
                    ""
    in
    "ws://" ++ url.host ++ port_ ++ "/ws"


type Route
    = Artist ArtistId
    | Album AlbumId
    | Playlist Int


parseUrl : Url -> Maybe Route
parseUrl =
    parse routeParser


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map (Artist << ArtistId) (s "artist" </> int)
        , map (Album << AlbumId) (s "album" </> int)
        , map Playlist (s "playlist" </> int)
        ]
