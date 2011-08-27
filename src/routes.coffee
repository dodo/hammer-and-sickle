{ DrawBuffer } = require './draw-buffer'

canvas = new DrawBuffer


module.exports = bind:(srv) ->
    srv.get '/', (req, res) ->
        res.render 'index', title:"test"

    # websocket

    connections = 0

    srv.ws.of('/raytracer').on 'connection', (client) ->
        client.emit 'view count', ++connections
        client.broadcast.emit 'view count', connections
        client.on 'disconnect', ->
            client.broadcast.emit 'view count', --connections

        client.on 'data', (data) ->
            canvas.drawBase64 0, 0, data

        listen = (data) ->
            client.emit 'data', data

        client.on 'pause', (paused) ->
            if paused
                canvas.removeListener 'data', listen
            else
                canvas.on 'data', listen
        return

