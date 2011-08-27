
{ Engine } = require '../include/rtrt'

class exports.Preview

    constructor: (@canvasid) ->

    start: =>
        @canvas = $(@canvasid)
        @engine = new Engine
            skysrc: "/img/sky.png"
            canvas: @canvas[0]
            quality: 1


        window.setInterval ( =>
            @engine.scene.camera.offset.start.x = 0.2
            @engine.scene.camera.offset.start.y = 0.3
            @engine.scene.camera.offset.stop.x = 0.8
            @engine.scene.camera.offset.stop.y = 0.7
            #@engine.camera
            @engine.tick()
        ), 5

        (button = $('#play.button')).click =>
            client.api.emit 'pause', @engine.running # inverted
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
            #client.api.emit 'data', data.slice(data.indexOf(',')+1)
