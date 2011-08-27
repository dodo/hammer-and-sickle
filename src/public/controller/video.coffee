
class exports.Video

    constructor: (@canvasid) ->

    start: =>
        @canvas = $(@canvasid)
        @ctx = @canvas[0].getContext '2d'

        client.api.on 'data', (data) =>
            console.log "data", data.length
            img = document.createElement 'img'
            img.onload = =>
                @ctx.drawImage img, 0, 0, img.width, img.height
            img.src = data
