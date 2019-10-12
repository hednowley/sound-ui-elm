module Views.Root exposing (view)

import Html
import Model exposing (Model)
import Msg exposing (Msg(..))
import Routing exposing (Route(..))
import Views.Artist
import Views.Home


view : Model -> Html.Html Msg
view model =
    case model.route of
        Nothing ->
            Views.Home.view model

        Just (Artist id) ->
            Views.Artist.view id model
