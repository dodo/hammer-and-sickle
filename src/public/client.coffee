require './backbone'

class Client

    start: =>
        $('<div>').text("yeah!").append('body')


module.exports = { client: window.client = client = new Client }
