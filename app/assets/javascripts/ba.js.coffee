class Ba

  dragging: false
  dragging_current_radius: 0
  dragging_type: null
  scaling_origin: null

  step_length: 400.0
  current_group: 0
  current_step_in_group: 0

  n_children: 0
  ids: []

  init: ->
    console.log("Init Ba.")
    Tity.Interact.init()
    @timePast = 0
    @e = $('#boxy')[0]
    @two = new Two({ fullscreen: true, type: Two.Types.svg }).appendTo(@e)

    @two.play()

    @initTs()

    @run()

  initTs: (yolo) ->
    circles = (@makeT() for x in [0...@n_children])
    @group = @two.makeGroup(circles)
    @updateIds()

    Tity.Peep.initPeeps(@group)

  makeT: (shape = 'circle', x = 'rand', y = 'rand', radius = 'rand') ->
    
    if radius is 'rand'
      radius = parseInt(10+(Math.random()*50))

    if x is 'rand'
      x = Math.min(Math.max(radius, parseInt(Math.random()*@two.width)), @two.width-radius)
    
    if y is 'rand'
      y = Math.min(Math.max(radius, parseInt(Math.random()*@two.height)), @two.height-radius)
    
    if shape is 'circle'
      shape = @two.makeCircle(x, y, radius)
      shape.fill = Tity.Util.randomBlue()
      shape.stroke = Tity.Util.randomBlue()
      shape.linewidth = 2
      shape.shape = 'circle'
      $("#two-"+shape.id).attr('class', 'blue')

    if shape is 'square'
      shape = @two.makeRectangle(x, y, radius, radius)
      shape.fill = Tity.Util.randomRed()
      shape.stroke = Tity.Util.randomRed()
      shape.linewidth = 2
      shape.shape = 'square'
      $("#two-"+shape.id).attr('class', 'red')

    shape.originalFill = shape.fill
    shape.highlighted = false

    shapeGroup = @two.makeGroup(shape)

    return shapeGroup

  updateTs: (frameCount) =>
    if @two.timeDelta
      @timePast += @two.timeDelta

    _.each @group.children, (subGroup) =>
      _.each subGroup.children, (child) =>
        if @dragging != child.id
          child.translation.x = child.translation.x + Math.sin((@timePast+child.translation.y)*(child.translation.y/20))
          child.translation.y = child.translation.y + Math.cos((@timePast+child.translation.y)*(child.translation.y/20))

        if not child.highlighted
          if @ids[@current_group]? and subGroup.id == @ids[@current_group].id
            child.opacity = 1
          else
            child.opacity = 0.2

    if @timePast > @step_length

      #if @ids[subGroup.id].length - 1 >= 

      @current_group += 1

      if @current_group >= @ids.length
        @current_group = 0

      if @ids.length > 0
        Tity.Peep.play(@ids[@current_group].id)

      @timePast = 0

  updateIds: ->
    @ids = []
    i = 0

    _.each @group.children, (subGroup) =>
      @ids[i] = {id: subGroup.id}
      @ids[i]['subGroup'] = _.map subGroup.children, (child) ->
        child.id  
      i+=1

  updateGroups: ->
    newGroup = @two.makeGroup()
    toRemove = []
    _.each @group.children, (subGroup) =>
      _.each subGroup.children, (child) =>
        if child.highlighted
          newGroup.add(child)
          subGroup.remove(child)
          toRemove.push(subGroup) if _.isEmpty(subGroup.children)
        else
          if _.keys(subGroup.children).length > 1
            subGroup.remove(child)
            @group.add(@two.makeGroup(child))

    _.each toRemove, (subGroup) =>
      @group.remove(subGroup)

    @group.add(newGroup) if not _.isEmpty(newGroup.children)
    @updateIds()

  run: ->
    @two.bind('update', (frameCount) =>
      @updateTs(frameCount)
    ).play()

$(document).ready ->
  Tity.Ba = new Ba()