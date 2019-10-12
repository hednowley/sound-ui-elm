module Ws.Methods.GetArtist exposing (getArtist)

import Json.Decode exposing (field, int, map2, string)
import Loadable exposing (Loadable(..))
import Model exposing (Model, removeListener)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.Listener exposing (Listener, makeIrresponsibleListener)
import Ws.Types exposing (RequestData)


type alias Body =
    { artist : Artist }


type alias Artist =
    { id : Int
    , name : String
    }


getArtist : RequestData
getArtist =
    { method = "getArtist"
    , params = Nothing
    , listener = Just onResponse
    }


responseDecoder : Json.Decode.Decoder Body
responseDecoder =
    Json.Decode.map Body
        (field "artist" <|
            map2 Artist
                (field "id" int)
                (field "name" string)
        )


onResponse : Listener Model Msg
onResponse =
    makeIrresponsibleListener
        (.id >> removeListener)
        responseDecoder
        setArtist


setArtist : Body -> Update Model Msg
setArtist body model =
    ( { model | artist = Loaded body.artist }, Cmd.none )
