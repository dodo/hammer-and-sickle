{ EventEmitter } = require 'events'
Canvas = require 'canvas'
{ Image } = Canvas

class exports.DrawBuffer extends EventEmitter
    constructor: () ->
        [@width, @height] = [320, 240]
        @canvas = new Canvas @width, @height
        @ctx = @canvas.getContext '2d'
        setInterval @propagate, 200

    propagate: =>
        return unless @listeners('data').length
        @canvas.toDataURL 'image/png', (err, data) =>
            @emit 'data', data unless err

    drawBase64: (x, y, data, callback) ->
        img = new Image
        img.onload = =>
            @ctx.drawImage img, x, y, img.width, img.height
            callback? img
        img.src = new Buffer data, 'base64'

