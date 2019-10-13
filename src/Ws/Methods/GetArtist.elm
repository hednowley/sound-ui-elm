module Ws.Methods.GetArtist exposing (getArtist)

import Json.Decode exposing (field, int, list, map3, map4, maybe, string)
import Json.Encode
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
    , albums : List Album
    }


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


responseDecoder : Json.Decode.Decoder Body
responseDecoder =
    Json.Decode.map Body
        (field "artist" <|
            map3 Artist
                (field "id" int)
                (field "name" string)
                (field "albums"
                    (list <|
                        map4 Album
                            (field "id" int)
                            (field "name" string)
                            (field "duration" int)
                            (maybe <| field "year" int)
                    )
                )
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
