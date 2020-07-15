module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Game exposing (..)
import Lamdera exposing (ClientId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , page : Page
    }


type Page
    = WelcomePage String
    | LobbyPage BackendModel


type BackendModel
    = WaitingToStart (List Player)
    | Pending (List Player)
    | Playing PlayingModel


type alias PlayingModel =
    { remainingDeck : List Card
    , deal : List Card
    , players : List Player
    }


type alias Player =
    { name : String
    , clientId : ClientId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | NameUpdated String
    | NameSubmitted
    | StartGameClicked


type ToBackend
    = UserArrived String
    | StartGame


type BackendMsg
    = NoOpBackendMsg
    | DeckShuffled (List Card)


type ToFrontend
    = BackendUpdated BackendModel
