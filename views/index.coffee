
div class:'pending textures container', ->
    text "loading textures ..."

div class:'video warning container', ->
    #canvas '#video', width:320, height:240
    video width:320, height:240, autoplay:'autoplay', src:"/stream", ->
        source src:"/stream", type:'video/webm; codecs="webm"'

div class:'right container', ->

    div class:'preview warning', ->
        canvas '#preview', width:64, height:48

    div class:'content container', ->
        p -> a '#participate.button', href:'#', "participate"
        p -> a '#play.button', href:'#', "▸ play"
        p '#viewer.info', "? viewers"
        p '#worker.info', "? workers"
        p '#fps.info',    "? fps"
