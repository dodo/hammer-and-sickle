
div class:'pending textures container', ->
    text "loading textures ..."

div class:'video warning container', ->
    canvas '#video', width:320, height:240

div class:'right container', ->

    div class:'preview warning', ->
        canvas '#preview', width:64, height:48

    div class:'content container', ->
        p -> a '#play.button', href:'#', "▸ play"
        p -> a '#participate.button', href:'#', "participate"
        p '#viewer.info', "? viewers"
        p '#worker.info', "? workers"
        p '#fps.info',    "? fps"
