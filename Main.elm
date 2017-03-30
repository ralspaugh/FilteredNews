import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import WebSocket


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- JSON

articleDecoder : Decoder Article
articleDecoder = map2 Article (field "text" string) (field "url" string)

jsonToArticle : String -> Maybe Article
jsonToArticle json = Result.toMaybe (decodeString articleDecoder json)


-- MODEL

type alias Model =
  { articles : List Article
  , filteredArticles : List Article
  , filters : List String
  }

init : ( Model, Cmd Msg )
init = ({articles = [], filteredArticles = [], filters = []}, Cmd.none)


-- UPDATE

type alias Article = { text: String, url: String }

type Msg = NewArticle String | FilterUpdate String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NewArticle json ->
      case jsonToArticle json of
        Just article ->
          ({ model | articles = (article :: model.articles), filteredArticles = (filterArticles model.filters (article :: model.articles)) }, Cmd.none)
        Nothing ->
          (model, Cmd.none)
    FilterUpdate text ->
      ({ model | filteredArticles = (filterArticles (String.split "," text) model.articles), filters = (String.split "," text) }, Cmd.none)

filterArticles : List String -> List Article -> List Article
filterArticles filters articles =
  if filters == [""] then articles else List.filter (\a -> articleFilter filters a) articles

articleFilter : List String -> Article -> Bool
articleFilter filters article =
  not (List.any (\filterText -> String.contains (String.toLower filterText) (String.toLower article.text)) filters)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080" NewArticle


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "page-container" ]
    [ div [ class "header" ] [ h1 [] [ text "Filtered News" ], small [] [ text "get the news you want." ], filtersView ]
    , div [ class "main-content" ] (List.map articleView model.filteredArticles)
    ]

articleView : Article -> Html Msg
articleView article =
  div [ class "article" ] [ a [ href article.url, target "_blank" ] [ text article.text ] ]

filtersView : Html Msg
filtersView =
  div [ class "filters" ] [ input [ placeholder "filters", onInput  FilterUpdate ] [] ]
