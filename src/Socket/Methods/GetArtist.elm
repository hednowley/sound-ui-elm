module Socket.Methods.GetArtist exposing (getArtist)

import Artist.Types exposing (ArtistId, getRawArtistId)
import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Socket.DTO.Artist exposing (Artist, convert, decode)
import Socket.Listener exposing (Listener, makeIrresponsibleListener)
import Socket.Types exposing (RequestData)
import Types exposing (Update)


getArtist : ArtistId -> RequestData
getArtist id =
    { method = "getArtist"
    , params = Just <| makeRequest id
    , listener = Just onResponse
    }


makeRequest : ArtistId -> Json.Encode.Value
makeRequest id =
    Json.Encode.object
        [ ( "id", Json.Encode.int (getRawArtistId id) ) ]


onResponse : Listener Model Msg
onResponse =
    makeIrresponsibleListener
        (.id >> removeListener)
        decode
        setArtist


setArtist : Artist -> Update Model Msg
setArtist artist model =
    ( { model | artist = Loaded (convert artist) }, Cmd.none )
