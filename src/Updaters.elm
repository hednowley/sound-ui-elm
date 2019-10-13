module Updaters exposing (logOut, onUrlChange)

import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Routing exposing (Route(..))
import Types exposing (Update)
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Methods.GetArtist exposing (getArtist)


logOut : Update Model Msg
logOut model =
    ( { model | username = "", token = Absent }, Ports.websocketClose () )


onUrlChange : Url -> Update Model Msg
onUrlChange url model =
    let
        m =
            { model | route = Routing.parseUrl url }
    in
    case m.route of
        Nothing ->
            ( m, Cmd.none )

        Just (Artist id) ->
            Ws.sendMessage
                (getArtist id)
                { m | artist = Loading }
