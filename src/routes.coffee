{ DrawBuffer } = require './draw-buffer'
{ random } = Math

canvas = new DrawBuffer


module.exports = bind:(srv) ->
    srv.get '/', (req, res) ->
        res.render 'index', title:"ray sucker"

    # websocket

    connections = 0
    workers = 0
    #count = 0
    pos = x:0, y:0

    srv.ws.of('/raytracer').on 'connection', (client) ->
        requested_tick = no
        last_time = -1

        client.emit 'view count', connections
        client.emit 'work count', workers

        client.on 'data', (data, x, y) ->
            canvas.drawBase64 x, y, data, last_time, ->
                requested_tick = yes

        next_tick = (now, size, t) ->
            return unless requested_tick
            requested_tick = no
            last_time = now

#             x = random() * (canvas.width  - 64 )
#             y = random() * (canvas.height - 48 )
#             start =
#                 x: x / canvas.width
#                 y: y / canvas.height
#             stop =
#                 x: ( x + 64 ) / canvas.width
#                 y: ( y + 48 ) / canvas.height


#             start =
#                 x: pos.x * 0.15
#                 y: pos.y * 0.15
#             stop =
#                 x: (pos.x + 1) * 0.15
#                 y: (pos.y + 1) * 0.15
#
#             pos.y++
#             if pos.y is 6
#                 pos.y = 0
#                 pos.x++
#                 if pos.x is 6
#                     pos.x = 0
#                     pos.y = 0

            start =
                x: pos.x * size
                y: pos.y * size
            stop =
                x: (pos.x + 1) * size
                y: (pos.y + 1) * size

            pos.x++
            if pos.x*size > 1
                pos.x = 0
                pos.y++
                if pos.y*size > 1
                    pos.y = 0
                    pos.x = 0

            #count++
            #count = 0 if count >= workers

            client.emit 'tick', { t, start, stop, size }

        listen = (data) ->
            client.emit 'data', data

        client.on 'run', (running) ->
            if running
                canvas.removeListener 'tick', next_tick
                requested_tick = no
            else
                canvas.on 'tick', next_tick
                requested_tick = yes
            workers = canvas.listeners('tick').length
            client.emit 'work count', workers
            client.broadcast.emit 'work count', workers

        client.on 'pause', (paused) ->
            if paused
                canvas.removeListener 'data', listen
            else
                canvas.on 'data', listen
            connections = canvas.listeners('data').length
            client.emit 'view count', connections
            client.broadcast.emit 'view count', connections

        client.on 'disconnect', ->
            canvas.removeListener 'data', listen
            canvas.removeListener 'tick', next_tick

        return

