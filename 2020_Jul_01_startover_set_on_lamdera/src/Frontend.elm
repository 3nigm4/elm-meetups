module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element, centerX, centerY, column, fill, focused, height, mouseOver, padding, px, rgb255, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , page = WelcomePage ""
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case ( msg, model.page ) of
        ( UrlClicked urlRequest, _ ) ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            ( model, Cmd.none )

        ( NoOpFrontendMsg, _ ) ->
            ( model, Cmd.none )

        ( NameUpdated updatedName, WelcomePage name ) ->
            ( { model | page = WelcomePage updatedName }, Cmd.none )

        ( NameSubmitted, WelcomePage name ) ->
            ( model, Lamdera.sendToBackend (UserArrived name) )

        ( StartGameClicked, LobbyPage backendModel ) ->
            ( model, Lamdera.sendToBackend StartGame )

        _ ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        BackendUpdated backendModel ->
            ( { model | page = LobbyPage backendModel }, Cmd.none )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body = [ Element.layout [ width fill, height fill ] (bodyView model) ]
    }


bodyView : FrontendModel -> Element FrontendMsg
bodyView model =
    case model.page of
        WelcomePage name ->
            Element.el [ width fill, height fill ] <|
                Element.column [ centerX, centerY, width (px 600), spacing 8 ]
                    [ nameInput name
                    , nameButton
                    ]

        LobbyPage (WaitingToStart players) ->
            column []
                [ playersList players
                , styledButton { onPress = StartGameClicked, label = "Start" }
                ]

        -- TODO Delete
        _ ->
            Element.text "invalid"


playersList : List Player -> Element FrontendMsg
playersList players =
    Element.column [] (List.map playerView players)


playerView : Player -> Element FrontendMsg
playerView player =
    Element.text player.name


nameInput : String -> Element FrontendMsg
nameInput name =
    Input.text []
        { onChange = NameUpdated
        , text = name
        , placeholder = Nothing
        , label = Input.labelAbove [] (Element.text "Name")
        }


nameButton : Element FrontendMsg
nameButton =
    styledButton { onPress = NameSubmitted, label = "Join" }


styledButton : { onPress : FrontendMsg, label : String } -> Element FrontendMsg
styledButton { onPress, label } =
    Input.button
        [ padding 20
        , Border.width 2
        , Border.rounded 16
        , Border.color <| rgb255 0x50 0x50 0x50
        , Border.shadow { offset = ( 4, 4 ), size = 3, blur = 10, color = rgb255 0xD0 0xD0 0xD0 }
        , Background.color <| rgb255 114 159 207
        , Font.color <| rgb255 0xFF 0xFF 0xFF
        , mouseOver
            [ Background.color <| rgb255 0xFF 0xFF 0xFF, Font.color <| rgb255 0 0 0 ]
        , focused
            [ Border.shadow { offset = ( 4, 4 ), size = 3, blur = 10, color = rgb255 114 159 207 } ]
        ]
        { onPress = Just onPress
        , label = Element.text label
        }
