module Audio.AudioMsg exposing (AudioMsg(..))

import Array exposing (Array)


type AudioMsg
    = CanPlay Int
    | Play Int
    | Resume
    | PlayItem Int
    | Pause
    | Queue Int
    | Ended Int
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
