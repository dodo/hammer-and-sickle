net = require 'net'
{ EventEmitter } = require 'events'
BufferStream = require 'bufferstream'
PostBuffer = require 'bufferstream/postbuffer'
Canvas = require 'canvas'
{ Image } = Canvas

len = 0
count = 0
class exports.DrawBuffer extends EventEmitter
    constructor: () ->
        [@width, @height] = [320, 240]
        @t = 0.0
        @mutex = off
        @source = net.createConnection 3030, 'localhost'
        @sink = net.createConnection 3020, 'localhost'

        @buffer =
            src: new BufferStream(encoding:'binary', size:'flexible')
        @buffer.src.disable()
        @buffer.src.pipe(@source)



        @canvas = new Canvas @width, @height
        @ctx = @canvas.getContext '2d'
        setInterval ( =>
            @tick()
            @propagate()
        ), 100

    propagate: =>
        if @mutex
            console.log "MUTEX!!!!!!!!!!!!"
            return
        if @buffer.src.buffer.length < 8000
            new PostBuffer(@canvas.createPNGStream()).onEnd @buffer.src.write
        else
            console.log "full", @buffer.src.buffer.length
        #@buffer.src.write '\r\n'
        #return unless @listeners('data').length

#         @canvas.toDataURL 'image/png', (err, data) =>
#             @emit 'data', data unless err

    tick: ->
        @emit 'tick', @t += 0.03

    drawBase64: (x, y, data, callback) ->
        img = new Image
        img.onload = =>
            @mutex = on
            @ctx.drawImage img, x*1.1, y*1.1, img.width, img.height
            @mutex = off
            callback? img
        img.src = new Buffer data, 'base64'

