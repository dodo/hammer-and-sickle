util = require 'util'
util.orginspect = util.inspect
util.inspect = require('eyes').inspector(stream: null)

require 'colors'
http = require 'http'
cli = require 'cli'
io = require 'socket.io'
io_session = require 'socket.io-sessions'
express = require 'express'
RedisStore = require('connect-redis')(express)
Master = require 'cluster/lib/master'
bridge = require 'cluster-socket.io'
cluster = require 'cluster'

class Cluster extends Master

    constructor: (@port = 3000, @host = 'localhost') ->
        super http.createServer()
        @http = require('./http') if @isWorker
        @configure()

    configure: () =>
        console.log("configuring #{['worker','master'][0+@isMaster]} server …")

        sessionstore = new RedisStore
        if @http
            @http.configure sessionstore
            @server = @http.server

        ws = @websocket = @server.ws = io_session.enable
            socket: io.listen(@server)
            parser: express.cookieParser()
            store: sessionstore

        ws.enable('browser client minification')
        ws.enable('browser client etag')
        ws.set('resource', "/websocket")
        ws.set('log level', 2)
        ws.set('transports', [
            'websocket'
            #'flashsocket'
            'xhr-polling'
            'jsonp-polling'
            'htmlfile'
        ])
        ws.set('close timeout', 5)
        ws.set('heartbeat timeout', 5)
        ws.set('heartbeat interval', 1)

        @set 'workers', 1 # socketio session bug
        @set 'socket path', '/tmp'
        @use cluster.debug()

        @use bridge(ws)
        @listen @port, @host
        if @isMaster
            console.log("http server listening on %s:%d …".magenta, @host, @port)
            require('nko') require '../../secret'

# exports

cli.parse
    address: ['b', "server listen address"
        'host', process.env.ADDRESS or "localhost"]
    port: ['p', "server listen port"
        'number', parseInt(process.env.PORT) or 3000]
    nobuild: [off, "[INTERNAL] disable build"]

cli.main (args, opts) ->
    module.exports.server = new Cluster opts.port, opts.address
