{ DrawBuffer } = require './draw-buffer'

canvas = new DrawBuffer


module.exports = bind:(srv) ->
    srv.get '/', (req, res) ->
        res.render 'index', title:"test"

    # websocket

    connections = 0

    srv.ws.of('/raytracer').on 'connection', (client) ->
        paused = yes
        client.emit 'view count', ++connections
        client.broadcast.emit 'view count', connections
        client.on 'disconnect', ->
            client.broadcast.emit 'view count', --connections

        client.on 'data', (data) ->
            canvas.drawBase64 0, 0, data

        client.on 'pause', (state) ->
            paused = state
