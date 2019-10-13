module Ws.Methods.GetAlbum exposing (getAlbum)

import Json.Decode exposing (field, int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.DTO.Album exposing (Album, convert, decode)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


getAlbum : Int -> RequestData
getAlbum id =
    { method = "getAlbum"
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
        setAlbum


setAlbum : Album -> Update Model Msg
setAlbum album model =
    ( { model | album = Loaded (convert album) }, Cmd.none )
