
div class:'video warning container', ->
    canvas '#video', width:300, height:180

div class:'right container', ->

    div class:'preview warning', ->
        canvas '#preview', width:48, height:48

    div class:'content container', ->
        p 'hello'
        p "world."
