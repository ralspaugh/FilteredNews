#!/usr/bin/env node
var WebSocket = require('ws');
var wss = new WebSocket.Server({ port: 8080 });
var config = require('./config');
var Twitter = require('node-tweet-stream');
var t = new Twitter(config);
var history = [];

wss.broadcast = function broadcast(data) {
  wss.clients.forEach(function each(client) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(data);
    }
  });
};

wss.on('connection', function connection(ws) {
  console.log('sending history');
  history.forEach(a => ws.send(JSON.stringify(a)));
});

// Who we follow
t.follow('3108351,7313362,807095,5695632,552151606,5392522'); // WSJ, Chicago Tribune, NY Times, Buzzfeed, DNAInfoCHI, NPR

t.on('tweet', function (tweet) {
    if (tweet.retweeted_status) {
      console.log('Retweet filtered - ' + tweet.text);
    } else if (tweet.in_reply_to_status_id !== null) {
      console.log('Status reply filtered - ' + tweet.text)
    } else if (tweet.in_reply_to_user_id !== null) {
      console.log('User reply filtered - ' + tweet.text)
    } else {
      var response = {
        text: tweet.user.screen_name + ' - ' + tweet.text,
        url: tweet.entities.urls.length > 0 ? tweet.entities.urls[0].url : ''
      };
      wss.broadcast(JSON.stringify(response));
      console.log('Tweet sent! - ' + tweet.text);
      history.unshift(response);
    }
});
