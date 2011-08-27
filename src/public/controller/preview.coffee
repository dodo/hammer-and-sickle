
{ Engine } = require '../include/rtrt'

class exports.Preview

    constructor: (@canvasid) ->

    start: =>
        @canvas = $(@canvasid)
        @engine = new Engine
            skysrc: "/img/sky.png"
            canvas: @canvas[0]
            quality: 0.4

        fps = $('#fps')
        @engine.fps.bind 'draw', (value) ->
            fps.text("#{value} fps")
        @engine.bind 'tick', ({canvas}) ->
            client.api.emit 'data', canvas.toDataURL()