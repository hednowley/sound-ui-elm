module Audio.Actions exposing
    ( goNext
    , goPrev
    , onSongEnded
    , onSongLoaded
    , onTimeChanged
    , pauseCurrent
    , playItem
    , queueAndPlaySong
    , queueSong
    , replacePlaylist
    , resumeCurrent
    , setCurrentTime
    , shuffle
    , shuffled
    , updateSongState
    )

import Array exposing (Array, append, fromList, length, push, slice)
import Audio exposing (makeLoadRequest)
import Audio.AudioMsg
import Audio.Select
    exposing
        ( getCurrentSongId
        , getCurrentSongState
        , getSongId
        , getSongState
        )
import AudioState exposing (State(..))
import Dict
import Loadable exposing (Loadable(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Random exposing (Generator)
import Random.Array exposing (shuffle)
import Routing exposing (Route(..))
import Song.Types exposing (SongId(..), getRawSongId)
import Types exposing (Update, combine)


updateSongState : SongId -> AudioState.State -> Model -> Model
updateSongState songId state model =
    let
        (SongId s) =
            songId
    in
    { model | songCache = Dict.insert s state model.songCache }


goNext : Update Model Msg
goNext model =
    case model.playing of
        Just index ->
            if Array.length model.playlist - 1 == index then
                -- No next song
                ( model, Cmd.none )

            else
                case getCurrentSongState model of
                    Just (Playing _) ->
                        playItem (index + 1) model

                    _ ->
                        case getCurrentSongId model of
                            Just songId ->
                                loadSong songId model

                            Nothing ->
                                ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


goPrev : Update Model Msg
goPrev model =
    case model.playing of
        Just index ->
            if index == 0 then
                playItem 0 model

            else
                case getCurrentSongState model of
                    Just (Playing { time }) ->
                        if time > 2 then
                            playItem index model

                        else
                            playItem (index - 1) model

                    _ ->
                        case getCurrentSongId model of
                            Just songId ->
                                loadSong songId model

                            Nothing ->
                                ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


shuffle : Update Model Msg
shuffle model =
    case model.playing of
        Just index ->
            let
                upcoming =
                    slice (index + 1) (length model.playlist) model.playlist
            in
            ( model
            , Random.generate
                (Msg.AudioMsg << Audio.AudioMsg.Shuffled)
                (Random.Array.shuffle upcoming)
            )

        Nothing ->
            ( model, Cmd.none )


shuffled : Array SongId -> Update Model Msg
shuffled s model =
    case model.playing of
        Just index ->
            let
                past =
                    slice 0 (index + 1) model.playlist
            in
            ( { model
                | playlist =
                    append past s
              }
            , Cmd.none
            )

        Nothing ->
            ( model, Cmd.none )


pauseCurrent : Update Model Msg
pauseCurrent model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.pauseAudio (getRawSongId songId) )

        Nothing ->
            ( model, Cmd.none )


setCurrentTime : Float -> Update Model Msg
setCurrentTime time model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.setAudioTime { songId = getRawSongId songId, time = time } )

        Nothing ->
            ( model, Cmd.none )


resumeCurrent : Update Model Msg
resumeCurrent model =
    case getCurrentSongId model of
        Just songId ->
            ( model, Ports.resumeAudio (getRawSongId songId) )

        Nothing ->
            ( model, Cmd.none )


onSongLoaded : SongId -> Update Model Msg
onSongLoaded songId model =
    let
        m =
            updateSongState
                songId
                (AudioState.Loaded { duration = Nothing })
                model

        playing =
            Maybe.andThen (getSongId model) model.playing
    in
    if playing == Just songId then
        playSong songId m

    else
        ( m, Cmd.none )


onTimeChanged : SongId -> Float -> Model -> Model
onTimeChanged songId time model =
    case getSongState songId model of
        Just (Playing p) ->
            updateSongState songId (Playing { p | time = time }) model

        _ ->
            model


playSong : SongId -> Update Model Msg
playSong songId model =
    case getSongState songId model of
        Just AudioState.Loading ->
            ( model, Cmd.none )

        Just (AudioState.Loaded _) ->
            ( model, Ports.playAudio (getRawSongId songId) )

        Just (AudioState.Playing _) ->
            ( model, Ports.playAudio (getRawSongId songId) )

        _ ->
            loadSong songId model


onSongEnded : Update Model Msg
onSongEnded model =
    case model.playing of
        Just index ->
            if Array.length model.playlist - 1 == index then
                -- The last song has finished
                ( { model | playing = Nothing }, Cmd.none )

            else
                playItem (index + 1) model

        Nothing ->
            ( model, Cmd.none )


playItem : Int -> Update Model Msg
playItem index model =
    case getSongId model index of
        Just songId ->
            model
                |> combine
                    pauseCurrent
                    (\m -> playSong songId { m | playing = Just index })

        Nothing ->
            ( model, Cmd.none )


replacePlaylistWithoutPausing : List SongId -> Update Model Msg
replacePlaylistWithoutPausing playlist model =
    let
        m =
            { model | playlist = fromList playlist }
    in
    case playlist of
        [] ->
            ( m, Cmd.none )

        first :: _ ->
            playSong first { m | playing = Just 0 }


replacePlaylist : List SongId -> Update Model Msg
replacePlaylist playlist =
    combine
        pauseCurrent
        (replacePlaylistWithoutPausing playlist)


queueAndPlaySong : SongId -> Update Model Msg
queueAndPlaySong songId model =
    let
        m =
            queueSong songId model
    in
    playItem (Array.length m.playlist - 1) m


queueSong : SongId -> Model -> Model
queueSong songId model =
    { model | playlist = push songId model.playlist }


loadSong : SongId -> Update Model Msg
loadSong songId model =
    let
        m =
            updateSongState songId AudioState.Loading model
    in
    ( m, Ports.loadAudio <| makeLoadRequest songId )
