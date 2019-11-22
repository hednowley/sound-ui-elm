module Audio.AudioMsg exposing (AudioMsg(..))

import Array exposing (Array)
import Song.Types exposing (SongId)


type AudioMsg
    = CanPlay SongId -- A song is ready to be played
    | Play SongId
    | Resume
    | PlayItem SongId
    | Pause
    | Queue SongId
    | Ended SongId
    | SetTime Float
    | TimeChanged { songId : Int, time : Float }
    | Playing { songId : Int, time : Float, duration : Maybe Float }
    | Paused { songId : Int, time : Float, duration : Maybe Float }
    | Next
    | Prev
    | PlayAlbum Int
    | PlayPlaylist Int
    | Shuffle
    | Shuffled (Array Int)
