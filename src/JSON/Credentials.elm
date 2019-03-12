module JSON.Credentials exposing (credentialsEncoder)

import Model
import Json.Encode

credentialsEncoder : Model.Model -> Json.Encode.Value
credentialsEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]
