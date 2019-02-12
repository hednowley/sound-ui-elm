module JSON.Authenticate exposing (Response, userEncoder, responseDecoder)

import Model
import Json.Decode exposing (Decoder, field, map2, string)
import Json.Encode

type alias Response =
    { status : String, token : String }


userEncoder : Model.Model -> Json.Encode.Value
userEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]


responseDecoder : Decoder Response
responseDecoder =
    map2 Response
        (field "status" string)
        (field "data" (field "token" string))