class Interact
  
  init: ->
    console.log('Init Interact.')
    @ba = Tity.Ba

    @initEvents()

  initEvents: ->
    $(window).on('mousedown', @godrags)
    $(window).on('mousemove', @drags)
    $(window).on('mouseup', @undrags)
    $(window).on('dblclick', @dblClickz)
    $(window).on('keyup', @keyUpEvents)

    $("#wtf").click(->
      $(@).stop().clearQueue().fadeOut(100))

    $("#helpme").mouseover(->
      $("#wtf").stop().clearQueue().fadeIn(100))

    $("#helpme").mouseout(->
      $("#wtf").stop().clearQueue().fadeOut(100))

    $("#helpme").animate({opacity: 0.6}, 5000)

  keyUpEvents: (e) =>
    
    @unhighlight() if e.keyCode == 27
    
    @ba.throttle('+') if e.keyCode == 187 and e.shiftKey
    @ba.throttle('-') if e.keyCode == 189

    switch String.fromCharCode(e.keyCode)
      when 'R'
        if @ba.step_order is 'inc'
          @ba.step_order = 'random' 
        else
          @ba.step_order = 'inc'
      when 'I'
        instruments = _.keys(Tity.Peep.instruments)
        currentIndex = instruments.indexOf(Tity.Peep.currentInstrument)
        console.log(currentIndex)
        console.log(instruments.length)
        console.log currentIndex >= instruments.length-1
        if currentIndex >= instruments.length-1
          currentIndex = 0
          console.log('=0')
          console.log(currentIndex)
        else
          currentIndex += 1
          console.log('+1')
          console.log(currentIndex)
        
        Tity.Peep.setInstrument(instruments[currentIndex])

  unhighlight: () ->
    _.each @ba.group.children, (subGroup) =>
      _.each subGroup.children, (child) =>
        child.highlighted = false
        child.fill = child.originalFill
        child.opacity = 0.2

  undrags: (e) =>
    if @ba.dragging
      Tity.Peep.updateGain(@ba.dragging)

    @ba.dragging = false
    @ba.dragging_type = null

  drags: (e) =>

    if @ba.dragging and @ba.dragging_type == 'move'
      @ba.dragging.translation.x = Math.min(Math.max(@ba.dragging_current_radius, e.clientX), @ba.two.width-@ba.dragging_current_radius)
      @ba.dragging.translation.y = Math.min(Math.max(@ba.dragging_current_radius, e.clientY), @ba.two.height-@ba.dragging_current_radius)
      hovering = false

    if @ba.dragging and @ba.dragging_type == 'scale'

      if ((e.clientY > @ba.scaling_origin.y and @ba.scaling_origin.y < @ba.dragging.translation.y) or (e.clientY < @ba.scaling_origin.y and @ba.scaling_origin.y > @ba.dragging.translation.y)) and @ba.dragging.getBoundingClientRect().height > 10
        @ba.dragging.scale *= 0.95

      if not ((e.clientY > @ba.scaling_origin.y and @ba.scaling_origin.y < @ba.dragging.translation.y) or (e.clientY < @ba.scaling_origin.y and @ba.scaling_origin.y > @ba.dragging.translation.y)) and @ba.dragging.getBoundingClientRect().height < 300
        @ba.dragging.scale *= 1.05

      # if (e.clientY > @ba.scaling_origin.y and @ba.scaling_origin.y > @ba.dragging.translation.y) or (e.clientY < @ba.scaling_origin.y and @ba.scaling_origin.y > @ba.dragging.translation.y) and @ba.dragging.getBoundingClientRect().height < 10
      #   @ba.dragging.scale *= 0.95

    unless @ba.dragging
      mouse = new Two.Vector(e.clientX, e.clientY)
      
      found = false

      _.each @ba.group.children, (subGroup) =>
        _.each subGroup.children, (child) =>
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
    
    unless @ba.dragging
      _.each @ba.group.children, (subGroup) =>
        _.each subGroup.children, (child) =>
          bound = child.getBoundingClientRect()

          center = {
            x: child.translation.x
            y: child.translation.y
          }
          
          distance = mouse.distanceTo(center)
          
          if distance < ((bound.width/2) - 10)
            @ba.dragging = child
            @ba.dragging_current_radius = bound.width/2
            @ba.dragging_type = 'move'

          if distance < ((bound.width/2)+30) && distance > ((bound.width/2)-10)
            @ba.dragging = child
            @ba.dragging_current_radius = bound.width/2
            @ba.dragging_type = 'scale'
            @ba.scaling_origin = mouse

  dblClickz: (e) =>
    mouse = new Two.Vector(e.clientX, e.clientY)

    found = false

    _.each @ba.group.children, (subGroup) =>
      _.each subGroup.children, (child, i) =>
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

          if not e.shiftKey
            subGroup.remove(child)
            @ba.group.remove(subGroup) if _.isEmpty(subGroup.children)
          
          if not (e.ctrlKey or e.shiftKey)
            
            newChild = @ba.makeT(newShape, child.translation.x, child.translation.y, child.getBoundingClientRect().height)

            _.each newChild.children, (child) =>
              Tity.Peep.setGenerator(child)

            if _.size(subGroup.children) > 0
              _.each newChild.children, (child) -> 
                child.inHarmon = 1
                child.addTo(subGroup)

              @ba.updateGroups()
            else
              newChild.addTo(@ba.group)

          @ba.updateIds()
          
          if e.shiftKey
            _.each @ba.group.children, (subGroup)->
              _.each subGroup.children, (child) ->
                child.inHarmon = 0

            if child.highlighted
              child.fill = child.originalFill
              child.opacity = 0.2
            else
              child.fill = Tity.Util.randomWhite()
              child.opacity = 1

            child.highlighted = !child.highlighted
            @ba.updateGroups()

          found = true
    
    unless found
      newChild = @ba.makeT('circle', e.clientX, e.clientY)
      newChild.addTo(@ba.group)
      @ba.updateIds()
      
      _.each newChild.children, (child) =>
        Tity.Peep.setGenerator(child)

$(document).ready ->
  Tity.Interact = new Interact()
