
require './underscore'
window.Backbone = Backbone = require 'backbone'

Backbone.Events.one = (event, callback) ->
    @bind event, eventcb = () ->
        @unbind event, eventcb
        callback.apply this, arguments


Backbone.View::one = Backbone.Model::one = Backbone.Collection::one =
    Backbone.Router::one = Backbone.Events.one

class Backbone.EventHandler
_.extend Backbone.EventHandler::, Backbone.Events

