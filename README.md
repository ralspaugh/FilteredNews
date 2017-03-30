# FilteredNews
Elm + Websockets + Twitter to create custom news feed

## Running
Build Elm front end

```
elm-make Main.elm --output main.js
```

Add Twitter API to config file

`filtered-news-server/config.json`:

```
{
  "consumer_key": "",
  "consumer_secret": "",
  "token": "",
  "token_secret": ""
}
```

Start node server

```
cd filtered-news-server
npm start
```

Open index.html
