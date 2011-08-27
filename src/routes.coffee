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

        [x, y] = [0, 0]
        client.on 'data', (data) ->
            canvas.drawBase64 x, y, data, (img) ->
                x += img.width
                if x >= canvas.width
                    x = 0
                    y += img.height
                    if y >= canvas.height
                        [x, y] = [0, 0]

        listen = (data) ->
            client.emit 'data', data

        client.on 'pause', (paused) ->
            if paused
                canvas.removeListener 'data', listen
            else
                canvas.on 'data', listen
        return

