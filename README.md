# FilteredNews
Elm + Websockets + Twitter to create custom news feed

## Running
Build Elm front end

```
elm-make Main.elm --output main.js
```

Add Twitter API keys to config file

`filtered-news-server/config.json`:

```
{
  "consumer_key": "",
  "consumer_secret": "",
  "token": "",
  "token_secret": ""
}
```

Install node package

```
cd filtered-news-server
npm install
```

Start node server

```
npm start
```

Open index.html
