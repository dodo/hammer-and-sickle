path = require 'path'
express = require 'express'
browserify = require 'browserify'
coffeekup = require 'coffeekup'
$_ = require 'underscore'
stylus = require 'stylus'
routes = require './routes'

minification = off # javascript minification
cwd = path.join(__dirname, "..", "..")

format = [
    "[:date]".grey
    ":status".green
    ":method".magenta
    ":url".yellow
].join " "


class HTTPServer
    constructor: () ->
        @server = express.createServer()

    set: => @server.set.apply @server, arguments
    register: => @server.register.apply @server, arguments
    use: (name, args...) =>
        console.log "* configure #{name} …" if off
        @server.use args...

    configure: (@sessionstore) =>
        @configure = @_configure()
        @create()

    _configure: =>
        debug: =>
            @use 'logger', express.logger {format}

        view: =>
            public_path = path.join(cwd, 'src', 'public')
            javascript = browserify
                mount  : '/js/require.js'
                watch  : yes
                fastmatch: true
                require: [
                    'underscore'
                    'backbone'
                    path.join(public_path, 'client')
                    jquery:'jquery-browserify'
                ]

            if minification
                javascript.register 'post', require('uglify-js')

            backbone = path.join(cwd, "node_modules", "backbone", "backbone.js")
            javascript.register 'pre', ->
                @files[backbone].body = @files[backbone].body.replace(
                    "var module = { exports : {} };",
                    "var module = { exports : {_:window._, jQuery:window.$} };")

            @use 'browserify', javascript
            @use 'favicon', express.favicon(path.join(cwd, "public", "img", "sphere.ico"))
            @use 'stylus', stylus.middleware
                src  : path.join(cwd, "public")
                paths: [path.join(cwd, "public")]
                debug: on

            @register '.coffee', coffeekup.adapters.express
            @set 'view engine', 'coffee'
            @set 'view options', { format: no }
            @set 'views', path.join(cwd, "views")

            @use 'static', express.static(path.join(cwd, "public"))

        session: =>
            @use 'session', express.session
                secret: "trolltrolltrolltrolltroll"
                store:@sessionstore

        error: =>
            @use 'errorHandler', express.errorHandler
                dumpExceptions: on
                showStack: yes

        request_parser: =>
            @use 'cookieParser', express.cookieParser()
            do @configure.session
            @use 'bodyParser', express.bodyParser()

        expose: =>
            @use 'router', @server.router

        basic: =>
            do @configure.debug
            do @configure.view
            do @configure.request_parser
            do @configure.expose
            do @configure.error

    create: =>
        @server.configure @configure.basic
        process.nextTick => routes.bind @server


# exports

module.exports = new HTTPServer
