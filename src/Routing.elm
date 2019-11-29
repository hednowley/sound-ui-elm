module Routing exposing (Route(..), getWebsocketUrl, parseUrl)

import Album.Types exposing (AlbumId(..))
import Artist.Types exposing (ArtistId(..))
import String exposing (fromInt)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s)
import Playlist.Types exposing (PlaylistId(..))


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
    | Playlist PlaylistId


parseUrl : Url -> Maybe Route
parseUrl =
    parse routeParser


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map (ArtistId >>  Artist) (s "artist" </> int)
        , map (AlbumId >> Album) (s "album" </> int)
        , map (PlaylistId >> Playlist) (s "playlist" </> int)
        ]
