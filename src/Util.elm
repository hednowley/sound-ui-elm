module Util exposing (maybeApply)

{-| Apply an optional transformation.
-}


maybeApply : Maybe (a -> a) -> a -> a
maybeApply maybeMap a =
    case maybeMap of
        Just map ->
            map a

        Nothing ->
            a
