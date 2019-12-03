module Views.Home exposing (view)

import Artist.Types exposing (getRawArtistId)
import Dict
import Entities.ArtistSummary exposing (ArtistSummaries)
import Entities.PlaylistSummary exposing (PlaylistSummaries)
import Html exposing (Html, a, button, div, input, label, span, text)
import Html.Attributes exposing (checked, class, href, type_)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Model -> Html.Html Msg
view model =
    div [ class "home__wrap" ]
        [ span [] [ text <| "Scanned: " ++ String.fromInt model.scanCount ]
        , button [ onClick LogOut ] [ text "Log out" ]
        , checkboxInput "Update?" model.scanShouldUpdate ToggleScanUpdate
        , checkboxInput "Delete?" model.scanShouldDelete ToggleScanDelete
        , button [ onClick StartScan ] [ text "Start scan" ]
        ]


checkboxInput : String -> Bool -> msg -> Html msg
checkboxInput name isChecked msg =
    label [] [ input [ checked isChecked, type_ "checkbox", onClick msg ] [], text name ]
