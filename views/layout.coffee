
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
        text "hello world"