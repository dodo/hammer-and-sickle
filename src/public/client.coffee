require './jquery'
require './console-dummy'
require './backbone'
{ Preview } = require './controller/preview'
{ Video } = require './controller/video'


class Router extends Backbone.Router
    routes:
        ""  : "index"
        "/" : "index"

    initialize: () ->
        Backbone.history.start pushState:on

    index: ->
        unless client.controller.video
            client.controller.video = video = new Video '#video'
            client.bind 'start', video.start

        unless client.controller.preview
            client.controller.preview = preview = new Preview '#preview'
            client.bind 'start', preview.start



class Client extends Backbone.EventEmitter

    constructor: () ->
        @started = no
        buffered_binds = []
        buffered_emits = []
        # dummy to accept emits and binds before api is booted
        @api =
            on: (name, callback) ->   buffered_binds.push {name, callback}
            emit: (name, args...) -> buffered_emits.push {name, args}
            fire: (api) ->
                for bind in buffered_binds
                    api.on bind.name, bind.callback
                for emit in buffered_emits
                    api.emit(emit.name, emit.args...)
        process.nextTick @initialize

    controller: {}

    initialize: =>
        @router = new Router
        @api.on 'view count', (viewer_count) ->
            $('#viewer').text("#{viewer_count} viewers")
        @api.on 'work count', (workers_count) ->
            $('#worker').text("#{workers_count} workers")

    start: =>
        dummy = @api
        @api = io.connect "/raytracer", resource:"websocket"
        @api.on 'connect', =>
            return if @started
            console.log "connected."
            dummy.fire @api
            @started = yes
            @trigger 'start'
        @api.on 'connecting', (type) =>
            console.log('try', type)

    bind: (name, callback) =>
        if name is 'start' and @started
            callback()
        else
            super

module.exports = { client: window.client = client = new Client }
