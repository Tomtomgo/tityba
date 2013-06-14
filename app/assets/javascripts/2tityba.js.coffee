class Tityba

  dragging: false
  dragging_current_radius: 0
  dragging_type: null
  scaling_origin: null

  step_length: 300.0
  current_step: 0

  n_children: 0
  ids: []

  init: ->
    @timePast = 0
    @e = $('#boxy')[0]
    @two = new Two({ fullscreen: true, type: Two.Types.svg }).appendTo(@e)

    @two.play()

    @initTs()

    @run()

  initTs: (yolo) ->
    circles = (@makeT() for x in [0...@n_children])
    @group = @two.makeGroup(circles)
    console.log(circles)
    @updateIds()

    ttp.initPeeps(@group)

    @initEvents()

  initEvents: ->
    $(window).on('mousedown', @godrags)
    $(window).on('mousemove', @drags)
    $(window).on('mouseup', @undrags)
    $(window).on('dblclick', @dblClickz)

  makeT: (shape = 'circle', x = 'rand', y = 'rand', radius = 'rand') ->
    
    if radius is 'rand'
      radius = parseInt(10+(Math.random()*50))

    if x is 'rand'
      x = Math.min(Math.max(radius, parseInt(Math.random()*@two.width)), @two.width-radius)
    
    if y is 'rand'
      y = Math.min(Math.max(radius, parseInt(Math.random()*@two.height)), @two.height-radius)
    
    if shape is 'circle'
      shape = @two.makeCircle(x, y, radius)
      shape.fill = @randomBlue()
      shape.stroke = @randomBlue()
      shape.linewidth = 2
      shape.shape = 'circle'
      $("#two-"+shape.id).attr('class', 'blue')

    if shape is 'square'
      shape = @two.makeRectangle(x, y, radius, radius)
      shape.fill = @randomRed()
      shape.stroke = @randomRed()
      shape.linewidth = 2
      shape.shape = 'square'
      $("#two-"+shape.id).attr('class', 'red')

    shape.rotdir = (Math.random()*2)-1
    shape.rotspd = Math.random()/100

    return shape

  updateTs: (frameCount) =>
    if @two.timeDelta
      @timePast += @two.timeDelta

    _.each @group.children, (child, i) =>
      if @dragging != child.id
        child.translation.x = child.translation.x + Math.sin((@timePast+child.translation.y)*(child.translation.y/20)) #* (child.translation.y/40)
        child.translation.y = child.translation.y + Math.cos((@timePast+child.translation.y)*(child.translation.y/20))

      #child.rotation += child.rotspd * child.rotdir

      if child.id == @ids[@current_step]
        child.opacity = 1
      else
        child.opacity = 0.2

    if @timePast > @step_length

      #@step_length = @step_length + (Math.sin(@timePast)*2)
      console.log(@step_length)

      @current_step += 1

      if @current_step >= @ids.length
        @current_step = 0

      if @ids.length > 0
        ttp.play(@ids[@current_step])

      @timePast = 0

  updateIds: ->
    @ids = _.map @group.children, (child) ->
      child.id
    console.log(@ids)

  undrags: (e) =>
    if @dragging
      ttp.updateGain(@dragging)

    @dragging = false
    @dragging_type = null

  drags: (e) =>

    if @dragging and @dragging_type == 'move'
      @dragging.translation.x = Math.min(Math.max(@dragging_current_radius, e.clientX), @two.width-@dragging_current_radius)
      @dragging.translation.y = Math.min(Math.max(@dragging_current_radius, e.clientY), @two.height-@dragging_current_radius)
      hovering = false

    if @dragging and @dragging_type == 'scale'

      if ((e.clientY > @scaling_origin.y and @scaling_origin.y < @dragging.translation.y) or (e.clientY < @scaling_origin.y and @scaling_origin.y > @dragging.translation.y)) and @dragging.getBoundingClientRect().height > 10
        @dragging.scale *= 0.95

      if not ((e.clientY > @scaling_origin.y and @scaling_origin.y < @dragging.translation.y) or (e.clientY < @scaling_origin.y and @scaling_origin.y > @dragging.translation.y)) and @dragging.getBoundingClientRect().height < 300
        @dragging.scale *= 1.05

      # if (e.clientY > @scaling_origin.y and @scaling_origin.y > @dragging.translation.y) or (e.clientY < @scaling_origin.y and @scaling_origin.y > @dragging.translation.y) and @dragging.getBoundingClientRect().height < 10
      #   @dragging.scale *= 0.95

    unless @dragging
      mouse = new Two.Vector(e.clientX, e.clientY)
      
      found = false

      _.each @group.children, (child) =>
        bound = child.getBoundingClientRect()

        center = {
          x: child.translation.x
          y: child.translation.y
        }
        
        distance = mouse.distanceTo(center)

        if distance < ((bound.width/2) - 10)
          $('html').css('cursor', 'move')
          found = true
        else if distance < ((bound.width/2)+30) && distance > ((bound.width/2)-10)
          $('html').css('cursor', 'ne-resize')
          found = true

      unless found
        $('html').css('cursor', 'default')
        

  godrags: (e) =>
    mouse = new Two.Vector(e.clientX, e.clientY)
    
    unless @dragging
      _.each @group.children, (child) =>
        bound = child.getBoundingClientRect()

        center = {
          x: child.translation.x
          y: child.translation.y
        }
        
        distance = mouse.distanceTo(center)
        
        if distance < ((bound.width/2) - 10)
          @dragging = child
          @dragging_current_radius = bound.width/2
          @dragging_type = 'move'

        if distance < ((bound.width/2)+30) && distance > ((bound.width/2)-10)
          @dragging = child
          @dragging_current_radius = bound.width/2
          @dragging_type = 'scale'
          @scaling_origin = mouse

  dblClickz: (e) =>
    mouse = new Two.Vector(e.clientX, e.clientY)

    found = false

    _.each @group.children, (child) =>
      bound = child.getBoundingClientRect()

      center = {
        x: child.translation.x
        y: child.translation.y
      }
      
      distance = mouse.distanceTo(center)
      
      if distance < (bound.width/2)
        
        if child.shape == 'circle'
          newShape = 'square'
        else
          newShape = 'circle'

        newChild = @makeT(newShape, child.translation.x, child.translation.y, child.getBoundingClientRect().height) unless e.ctrlKey

        @group.remove(child)
        newChild.addTo(@group) unless e.ctrlKey

        @updateIds()

        ttp.destroyGenerator(child)
        ttp.addGenerator(newChild) unless e.ctrlKey

        found = true
    
    unless found
      newChild = @makeT('circle', e.clientX, e.clientY)
      newChild.addTo(@group)
      @updateIds()
      ttp.addGenerator(newChild)

  run: ->
    @two.bind('update', (frameCount) =>
      @updateTs(frameCount)
    ).play()
  
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

$(document).ready ->

  window.ttb = new Tityba()
  window.ttb.init()