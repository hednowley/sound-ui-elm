module Player.Msg exposing (PlayerMsg(..))

import Album.Types exposing (AlbumId)
import Array exposing (Array)
import Song.Types exposing (SongId)


type PlayerMsg
    = Play SongId
    | PlayItem Int
    | Pause
    | Resume
    | Queue SongId
    | PlayAlbum AlbumId
    | PlayPlaylist Int
    | Next
    | Prev
    | SetShuffle Bool
    | Shuffled (Array SongId)
