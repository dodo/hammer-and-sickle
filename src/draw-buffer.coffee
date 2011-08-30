net = require 'net'
{ EventEmitter } = require 'events'
BufferStream = require 'bufferstream'
PostBuffer = require 'bufferstream/postbuffer'
Canvas = require 'canvas'
{ Image } = Canvas


class exports.DrawBuffer extends EventEmitter
    constructor: () ->
        [@width, @height] = [320, 240]
        @t = 0.0
        @count = 0

        @source = net.createConnection 3030, 'localhost'
        @sink = net.createConnection 3020, 'localhost'

        @buffer =
            src: new BufferStream(encoding:'binary', size:'none')
        @buffer.src.disable()
        @buffer.src.pipe(@source)



        @canvas = new Canvas @width, @height
        @ctx = @canvas.getContext '2d'
#         setInterval ( =>
#             @tick()
#             #@propagate()
#         ), 100
        setTimeout @tick, 50

    propagate: =>
        new PostBuffer(@canvas.createPNGStream()).onEnd @buffer.src.write

    tick: =>
        workers = @listeners('tick').length
        size = 1 / workers
        @count = 0
        @emit 'tick', (new Date).getTime(), size, @t += 0.03
        @propagate()
        @timeout = setTimeout @tick, 150

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
            @ctx.drawImage img, x*0.95, y*0.95, img.width*size*1.05, img.height*size*1.05
            callback? img

            @count++
            if count >= workers
                clearTimeout @timeout
                @tick()

        img.src = new Buffer data, 'base64'

