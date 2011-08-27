{ EventEmitter } = require 'events'
Canvas = require 'canvas'
{ Image } = Canvas

class exports.DrawBuffer extends EventEmitter
    constructor: () ->
        @canvas = new Canvas 300, 180
        @ctx = @canvas.getContext '2d'
        setInterval @propagate, 1000

    propagate: =>
        return unless @listeners('data').length
        @canvas.toDataURL 'image/png', (err, data) =>
            @emit 'data', data unless err

    drawBase64: (x, y, data) ->
        img = new Image
        img.src = new Buffer data, 'base64'
        @ctx.drawImage img, x, y, img.width, img.height

