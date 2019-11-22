module Audio.Update exposing (update)

import Album.Update exposing (playAlbum)
import Audio.Actions
    exposing
        ( goNext
        , goPrev
        , onSongEnded
        , onSongLoaded
        , onTimeChanged
        , pauseCurrent
        , playItem
        , queueAndPlaySong
        , queueSong
        , resumeCurrent
        , setCurrentTime
        , shuffle
        , shuffled
        , updateSongState
        )
import Audio.AudioMsg exposing (AudioMsg(..))
import AudioState
import Loadable exposing (Loadable(..))
import Model exposing (Listeners, Model)
import Msg exposing (Msg(..))
import Playlist.Update exposing (playPlaylist)
import Rest.Core as Rest
import Types exposing (Update)
import Ws.Core exposing (messageIn, sendMessage)
import Ws.Methods.Handshake
import Ws.Methods.Start


update : AudioMsg -> Update Model Msg
update msg model =
    case msg of
        CanPlay songId ->
            onSongLoaded songId model

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

        Ended _ ->
            onSongEnded model

        SetTime time ->
            setCurrentTime time model

        Playing { songId, time, duration } ->
            ( updateSongState
                songId
                (AudioState.Playing { paused = False, time = time, duration = duration })
                model
            , Cmd.none
            )

        Paused { songId, time, duration } ->
            ( updateSongState
                songId
                (AudioState.Playing { paused = True, time = time, duration = duration })
                model
            , Cmd.none
            )

        TimeChanged args ->
            ( onTimeChanged args.songId args.time model, Cmd.none )

        Next ->
            goNext model

        Prev ->
            goPrev model

        Shuffle ->
            shuffle model

        Shuffled playlist ->
            shuffled playlist model
