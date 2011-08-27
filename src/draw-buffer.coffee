Canvas = require 'canvas'
{ Image } = Canvas

class exports.DrawBuffer
    constructor: () ->
        @canvas = new Canvas 300, 180
        @ctx = @canvas.getContext '2d'

    drawBase64: (x, y, data) ->
        img = new Image
        img.src = new Buffer data, 'base64'
        @ctx.drawImage img, x, y, img.width, img.height
