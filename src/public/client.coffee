require './backbone'

class Client

    start: =>
        $('body').append($('<div>').text("yeah!"))


module.exports = { client: window.client = client = new Client }
