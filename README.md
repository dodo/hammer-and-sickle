# ray sucker by ☭

![nko2 screenshot](http://pinkyurl.com/i?url=http%3A%2F%2Fhammer-and-sickle.nko2.nodeknockout.com%2F&out-format=png&resize=160x93)

It sucks on every cpu to generate on big (well … bigger) realtime raytraced live video.

to see the current state of the scene just press ‘start’ to warm up your cpu, just press ‘participate’ (enables view too).

ray sucker is supposed to be show case that nodejs is suitable even for realtime raytracing.

### technical
every client draws a small area of one big frame and sends it to the server. the server draws everything into one canvas and returns the big frame to every client. all data is base64 encoded transferred over websockets.

## Judging Instructions
best works in chromium/chrome/safari (faster) and opera (more stable)

sometimes the buttons doesn’t react at first action, so please feel free to penetrate them (just press ‘em hard and often :D)

in the gstreamer branch is a newer version, but it doesn' work :( (gstreamer receives defect png data when some client parts are drawn onto server canvas)

## How

```javascript
{ "dependencies": {
    "nko": ""
,   "coffee-script": ""
,   "bufferstream": ""
,   "eyes": ""
,   "colors": ""
,   "cli": ""
,   "express": ""
,   "coffeekup": ""
,   "stylus": ""
,   "cluster": ""
,   "cluster-socket.io": ""
,   "socket.io": ""
,   "socket.io-sessions": ""
,   "connect-redis": ""
,   "log": ""
,   "browserify": ""
,   "jquery-browserify": ""
,   "underscore": ""
,   "backbone": ""
,   "canvas": ""
  },
  "other": {
    "node-waf": ""
,   "python": ""
,   "gstreamer": ""
}
```

