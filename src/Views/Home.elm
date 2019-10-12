module Views.Home exposing (view)

import Browser
import Dict exposing (Dict)
import Entities.Artist exposing (Artists)
import Html exposing (Html, a, button, div, form, input, label, section, span, text)
import Html.Attributes exposing (checked, class, disabled, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Model exposing (Model)
import Msg exposing (Msg(..))
import String exposing (fromInt)


view : Model -> Html.Html Msg
view model =
    div [ class "home__wrap" ]
        [ span [] [ text model.message ]
        , span [] [ text <| "Scanned: " ++ String.fromInt model.scanCount ]
        , button [ onClick LogOut ] [ text "Log out" ]
        , checkboxInput "Update?" model.scanShouldUpdate ToggleScanUpdate
        , checkboxInput "Delete?" model.scanShouldDelete ToggleScanDelete
        , button [ onClick StartScan ] [ text "Start scan" ]
        , viewArtists model.artists
        ]


checkboxInput : String -> Bool -> msg -> Html msg
checkboxInput name isChecked msg =
    label [] [ input [ checked isChecked, type_ "checkbox", onClick msg ] [], text name ]


viewArtists : Artists -> Html msg
viewArtists artists =
    div [ class "home__artists" ]
        (List.map
            (\artist -> div [ class "home__artist" ] [ a [ href <| "/artist/" ++ fromInt artist.id ] [ text artist.name ] ])
            (Dict.values artists)
        )
