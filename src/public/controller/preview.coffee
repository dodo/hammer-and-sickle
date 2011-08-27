
{ Engine } = require '../include/rtrt'

class exports.Preview

    constructor: (@canvasid) ->

    start: =>
        @canvas = $(@canvasid)
        @engine = new Engine
            skysrc: "/img/sky.png"
            canvas: @canvas[0]
            quality: 0.4

        (button = $('#play.button')).click =>
            @engine.running = !@engine.running
            button.text ["▸ play", "■ stop"][0+@engine.running]
            return false

        fps = $('#fps')
        pending_textures = $('.pending.textures')
        @engine.fps.bind 'draw', (value) ->
            fps.text("#{value} fps")

        @engine.bind 'tick', ({canvas}) ->
            pending_textures.hide()
            data = canvas.toDataURL()
            client.api.emit 'data', data.slice(data.indexOf(',')+1)
