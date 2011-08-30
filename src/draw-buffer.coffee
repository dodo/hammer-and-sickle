{ EventEmitter } = require 'events'
Canvas = require 'canvas'
{ Image } = Canvas

class exports.DrawBuffer extends EventEmitter
    constructor: () ->
        [@width, @height] = [320, 240]
        @t = 0.0
        @canvas = new Canvas @width, @height
        @ctx = @canvas.getContext '2d'
        setInterval ( =>
            @tick()
            #@propagate()
        ), 100
        setInterval ( =>
            #@tick()
            @propagate()
        ), 150

    propagate: =>
        return unless @listeners('data').length
        @canvas.toDataURL 'image/png', (err, data) =>
            @emit 'data', data unless err

    tick: =>
        workers = @listeners('tick').length
        size = 1 / workers
        @emit 'tick', (new Date).getTime(), size, @t += 0.03

    drawBase64: (x, y, data, last_time, callback) ->
        d = (new Date).getTime() - last_time
        if d > 200 # drop frame part
            return callback? null
        #alpha = d * 0.005

        workers = @listeners('tick').length
        size = 5 / workers

        img = new Image
        img.onload = =>
            #@ctx.globalAlpha = alpha
            @ctx.drawImage img, x, y, img.width*size, img.height*size
            callback? img
        img.src = new Buffer data, 'base64'

