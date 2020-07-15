module Backend exposing (..)

import Game exposing (..)
import Html
import Lamdera exposing (ClientId, SessionId)
import Random
import Random.List exposing (shuffle)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( WaitingToStart []
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case ( msg, model ) of
        ( DeckShuffled cards, Pending players ) ->
            -- TODO - START HERE
            ( model, Cmd.none )

        ( NoOpBackendMsg, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case ( msg, model ) of
        ( UserArrived name, WaitingToStart players ) ->
            let
                updatedModel =
                    WaitingToStart ({ clientId = clientId, name = name } :: players)
            in
            ( updatedModel, Lamdera.broadcast (BackendUpdated updatedModel) )

        ( StartGame, WaitingToStart players ) ->
            ( Pending players, Random.generate DeckShuffled <| shuffle deck )

        _ ->
            ( model, Cmd.none )
