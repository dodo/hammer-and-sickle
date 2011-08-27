{ DrawBuffer } = require './draw-buffer'
{ random } = Math

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

        next_tick = ->
            x = random() * canvas.width
            y = random() * canvas.height
            start =
                x: (x - 64) / canvas.width
                y: (y - 48) / canvas.height
            stop =
                x: x / canvas.width
                y: y / canvas.height
            client.emit 'tick', { start, stop }

        client.on 'data', (data, x, y) ->
            canvas.drawBase64 x, y, data, next_tick

        listen = (data) ->
            client.emit 'data', data

        client.on 'pause', (paused) ->
            if paused
                canvas.removeListener 'data', listen
            else
                canvas.on 'data', listen
                next_tick()
        return

