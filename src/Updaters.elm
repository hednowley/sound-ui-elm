module Updaters exposing (loadSong, logOut, onUrlChange, playSong)

import Audio exposing (makeLoadRequest)
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Routing exposing (Route(..))
import Types exposing (Update)
import Url exposing (Url)
import Ws.Core as Ws
import Ws.Methods.GetAlbum exposing (getAlbum)
import Ws.Methods.GetArtist exposing (getArtist)


logOut : Update Model Msg
logOut model =
    ( { model | username = "", token = Absent }, Ports.websocketClose () )


loadSong : Int -> Update Model Msg
loadSong id model =
    ( { model | shouldPlay = True }, Ports.loadAudio <| makeLoadRequest model id )


playSong : Int -> Update Model Msg
playSong songId model =
    ( { model | playing = Just songId }, Ports.playAudio songId )


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

        Just (Album id) ->
            Ws.sendMessage
                (getAlbum id)
                { m | album = Loading }
