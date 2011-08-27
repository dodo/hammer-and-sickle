
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
        @engine.fps.callback = (value) ->
            fps.text("#{value} fps")