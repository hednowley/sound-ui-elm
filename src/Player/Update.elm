module Player.Update exposing (update)

import Album.Update exposing (playAlbum)
import Audio.Actions exposing (onSongLoaded, onTimeChanged, updateSongState)
import Audio.AudioMsg exposing (AudioMsg(..))
import AudioState
import Model exposing (Model)
import Msg
import Player.Actions
    exposing
        ( goNext
        , goPrev
        , onSongEnded
        , pauseCurrent
        , playItem
        , queueAndPlaySong
        , queueSong
        , resumeCurrent
        , setCurrentTime
        , shuffle
        , shuffled
        )
import Player.Msg exposing (PlayerMsg(..))
import Playlist.Update exposing (playPlaylist)
import Song.Types exposing (SongId(..))
import Types exposing (Update)


update : PlayerMsg -> Update Model Msg.Msg
update msg model =
    case msg of
        PlayItem index ->
            playItem index model

        Play songId ->
            queueAndPlaySong songId model

        PlayAlbum albumId ->
            playAlbum albumId model

        PlayPlaylist playlistId ->
            playPlaylist playlistId model

        Pause ->
            pauseCurrent model

        Resume ->
            resumeCurrent model

        Queue songId ->
            ( queueSong songId model, Cmd.none )

        Next ->
            goNext model

        Prev ->
            goPrev model

        Shuffle ->
            shuffle model

        Shuffled playlist ->
            ( shuffled playlist model, Cmd.none )
