module Ws.Methods.GetArtist exposing (getArtist)

import Json.Decode exposing (field, int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.DTO.Artist exposing (Artist, convert, decode)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


getArtist : Int -> RequestData
getArtist id =
    { method = "getArtist"
    , params = makeRequest id |> Just
    , listener = Just onResponse
    }


makeRequest : Int -> Json.Encode.Value
makeRequest id =
    Json.Encode.object
        [ ( "id", Json.Encode.int id ) ]


onResponse : Listener Model Msg
onResponse =
    makeIrresponsibleListener
        (.id >> removeListener)
        decode
        setArtist


setArtist : Artist -> Update Model Msg
setArtist artist model =
    ( { model | artist = Loaded (convert artist) }, Cmd.none )
