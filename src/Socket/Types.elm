module Socket.Types exposing (MessageId(..), getRawMessageId)

import Msg exposing (Msg)


type MessageId
    = MessageId Int


getRawMessageId : MessageId -> Int
getRawMessageId messageId =
    let
        (MessageId id) =
            messageId
    in
    id
