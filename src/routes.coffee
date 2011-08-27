
module.exports = bind:(srv) ->
    srv.get '/', (req, res) ->
        res.render 'index', title:"test"

    # websocket

    srv.ws.of('/raytracer').on 'connection', (socket) ->

