module Types exposing (Update, combine, noOp)


type alias Update model msg =
    model -> ( model, Cmd msg )


noOp : Update model msg
noOp model =
    ( model, Cmd.none )


{-| Running one update and then another.
-}
combine : Update model msg -> Update model msg -> Update model msg
combine updateA updateB model =
    let
        ( modelA, cmdA ) =
            updateA model

        ( modelB, cmdB ) =
            updateB modelA
    in
    ( modelB, Cmd.batch [ cmdB, cmdA ] )
