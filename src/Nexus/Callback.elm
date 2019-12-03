module Nexus.Callback exposing (Callback, combine)

import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update)


type alias Callback a =
    a -> Update Model Msg


resolve : Maybe (Callback a) -> Callback a
resolve maybeCallback =
    Maybe.withDefault
        (\a -> \m -> ( m, Cmd.none ))
        maybeCallback


combine : Maybe (Callback a) -> Maybe (Callback a) -> Callback a
combine maybeA maybeB obj =
    Types.combine
        (resolve maybeA obj)
        (resolve maybeB obj)
