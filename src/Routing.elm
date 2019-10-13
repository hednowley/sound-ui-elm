module Routing exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s)


type Route
    = Artist Int
    | Album Int


parseUrl : Url -> Maybe Route
parseUrl =
    parse routeParser


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Artist (s "artist" </> int)
        , map Album (s "album" </> int)
        ]