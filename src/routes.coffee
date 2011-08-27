
module.exports = bind:(srv) ->
    srv.get '/', (req, res) ->
        res.render 'index', title:"test"

