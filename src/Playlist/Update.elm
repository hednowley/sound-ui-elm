module Playlist.Update exposing (loadPlaylist, playPlaylist)

import Audio.Update exposing (replacePlaylist)
import Dict
import Entities.Playlist exposing (Playlist)
import Loadable exposing (Loadable(..))
import Model exposing (Model, addListener)
import Msg exposing (AudioMsg(..), Msg(..))
import Playlist.Select exposing (getPlaylistSongs)
import Types exposing (Update, noOp)
import Ws.Core exposing (sendMessage)
import Ws.Methods.GetPlaylist exposing (getPlaylist)


loadPlaylist : Int -> Maybe (Playlist -> Update Model Msg) -> Update Model Msg
loadPlaylist id callback model =
    sendMessage
        (getPlaylist id callback)
        { model | loadedPlaylists = Dict.insert id Loading model.loadedPlaylists }


loadPlaylist2 : Int -> Maybe (Playlist -> Update Model Msg) -> Update Model Msg
loadPlaylist2 id maybeCallback model =
    case Playlist.Select.getPlaylist id model of
        Absent ->
            sendMessage
                (getPlaylist id maybeCallback)
                { model | loadedPlaylists = Dict.insert id Loading model.loadedPlaylists }

        Loading requestId ->
            case maybeCallback of
                Just callback ->
                    ( addListener requestId callback model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Loaded playlist ->
            case maybeCallback of
                Just callback ->
                    callback playlist model

                Nothing ->
                    ( model, Cmd.none )


playLoadedPlaylist : Playlist -> Update Model Msg
playLoadedPlaylist playlist =
    let
        songs =
            List.map .id (getPlaylistSongs playlist)
    in
    replacePlaylist songs


playPlaylist : Int -> Update Model Msg
playPlaylist playlistId =
    loadPlaylist
        playlistId
        (Just playLoadedPlaylist)
