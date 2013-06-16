class Util
  
  randomBlue: ->
    r = parseInt(10+(Math.random()*80))
    g = parseInt(10+(Math.random()*80))
    
    "rgba(#{r}, #{g}, 255, 1)"

  randomRed: ->
    g = parseInt(10+(Math.random()*80))
    b = parseInt(10+(Math.random()*80))
    
    "rgba(255, #{g}, #{b}, 1)"

  randomGreen: ->
    r = parseInt(10+(Math.random()*80))
    b = parseInt(10+(Math.random()*80))
    
    "rgba(#{r}, 255, #{b}, 1)"

  randomWhite: ->
    r = parseInt(230+(Math.random()*25))
    g = parseInt(230+(Math.random()*25))
    b = parseInt(230+(Math.random()*25))
    
    "rgba(#{r}, #{g}, #{b}, 1)"

$(document).ready ->
  Tity.Util = new Util()