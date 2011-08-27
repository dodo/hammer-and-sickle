
{ Engine } = require '../include/rtrt'

class exports.Preview

    constructor: (@canvasid) ->

    start: =>
        @canvas = $(@canvasid)
        @engine = new Engine
            skysrc: "/img/sky.png"
            canvas: @canvas[0]
            quality: 1.0

        client.api.on 'tick', ({t, start, stop}) =>
            #console.log 'in', start.x, start.y, stop.x, stop.y
            @engine.scene.camera.offset.start.x = start.x
            @engine.scene.camera.offset.start.y = start.y
            @engine.scene.camera.offset.stop.x = stop.x
            @engine.scene.camera.offset.stop.y = stop.y
            @engine.animator.t = t
            @engine.tick()

        paused = yes
        (play_button = $('#play.button')).click pause = =>
            paused = !paused
            client.api.emit 'pause', paused
            play_button.text ["■ stop", "▸ play"][0+paused]
            return false

        (part_button = $('#participate.button')).click =>
            client.api.emit 'run', @engine.running # inverted
            @engine.running = !@engine.running
            part_button.text ["participate", "halt"][0+@engine.running]
            do pause if paused and @engine.running
            return false


        fps = $('#fps')
        pending_textures = $('.pending.textures')
        @engine.fps.bind 'draw', (value) ->
            fps.text("#{value} fps")

        @engine.bind 'tick', ({canvas, renderer}) ->
            pending_textures.hide()
            data = canvas.toDataURL()
            c = client.controller.video.canvas[0]
            p = renderer.getPos(c.width, c.height)
            #console.log "out", p.x, p.y
            client.api.emit 'data', data.slice(data.indexOf(',')+1), p.x, p.y

