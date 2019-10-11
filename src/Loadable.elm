module Loadable exposing (Loadable(..), fromMaybe, toMaybe)


type Loadable value
    = Absent
    | Loading
    | Loaded value


toMaybe : Loadable value -> Maybe value
toMaybe loadable =
    case loadable of
        Loaded v ->
            Just v

        _ ->
            Nothing


fromMaybe : Maybe value -> Loadable value
fromMaybe maybe =
    case maybe of
        Just v ->
            Loaded v

        _ ->
            Absent
