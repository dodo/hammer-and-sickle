
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
