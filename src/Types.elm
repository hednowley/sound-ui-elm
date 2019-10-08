module Types exposing (Update,  noOp)


type alias Update model msg =
    model -> ( model, Cmd msg )


noOp : Update model msg
noOp model =
    ( model, Cmd.none )
