
div class:'video warning container', ->
    canvas '#video', width:300, height:180

div class:'right container', ->

    div class:'preview warning', ->
        canvas '#preview', width:48, height:48

    div class:'content container', ->
        p ->
            a class:'button', href:'#', "participate"
        p '#viewer.info', "? viewers"
        p '#worker.info', "? workers"
        p '#fps.info',    "? fps"
