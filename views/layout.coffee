
doctype 5
html ->
    head ->
        title @title
        link rel: 'stylesheet', href: "/css/normalize.css"
        link rel: 'stylesheet', href: "/css/style.css"
        script src: "/websocket/socket.io.js"
        script src: "/js/require.js"
        coffeescript ->
            require './jquery'
            { client } = require './client'
            $('document').ready client.start
    body ->
        div '.body', @body
        iframe
            src:"http://nodeknockout.com/iframe/hammer-and-sickle"
            frameborder:0
            scrolling:  0
            allowtransparency:true
            width: 115
            height: 25
