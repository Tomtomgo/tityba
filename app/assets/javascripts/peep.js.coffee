class Peep

  instruments:
    'brom': {ramps: {in:0.01, out:0.01}, oscTypes: {circle: 0, square: 1}, 1, dur: 0.1}
    'blar': {ramps: {in:0.1, out:0.01}, oscTypes: {circle: 0, square: 2}, dur: 0.4}
    'blor': {ramps: {in:0.05, out:0.05}, oscTypes: {circle: 2, square: 3}, dur: 0.1}
    'iep': {ramps: {in:0.001, out:0.01}, oscTypes: {circle: 3, square: 2}, dur: 0.03}

  currentInstrument: 'brom'

  initPeeps: (speed) ->
    console.log("Init Peep.")
    
    @ba = Tity.Ba

    @speed = speed

    @context = new webkitAudioContext()
    
    @initOutput() # Connect the output

    @initGenerators() # Init and connect the generators

    @initEffects()

  initOutput: ->
    @inNode = @context.createGainNode()
    @inNode.gain.value = 1.0

    @outGainNode = @context.createGainNode()
    @outGainNode.gain.value = 0.6

    @inNode.connect(@outGainNode)
    @outGainNode.connect(@context.destination)

  initGenerators: ->

    _.each @ba.group.children, (subGroup) =>
      _.each subGroup.children, (child) =>
        child.peepObj = {}

        child.peepObj['gainVal'] = ((10+child.getBoundingClientRect().height)/290)

        child.peepObj['gainNode'] = @context.createGainNode()
        child.peepObj['gainNode'].gain.value = 0
        child.peepObj['gainNode'].connect(@inNode)
        
        child.peepObj['oscNode'] = @context.createOscillator()
        child.peepObj['oscNode'].type = 0
        child.peepObj['oscNode'].frequency.value = 0
        child.peepObj['oscNode'].connect(child.peepObj['gainNode'])
        child.peepObj['oscNode'].noteOn(0)

  setGenerator: (child) ->
    
    if child.shape == 'square'
      gainMul = 0.5

    if child.shape == 'circle'
      gainMul = 1

    child.peepObj = {}

    child.peepObj['gainVal'] = ((10+child.getBoundingClientRect().height)/290)

    child.peepObj['gainNode'] = @context.createGainNode()
    child.peepObj['gainNode'].gain.value = child.peepObj['gainVal']*gainMul
    child.peepObj['gainNode'].connect(@inNode)
    
    child.peepObj['oscNode'] = @context.createOscillator()
    child.peepObj['oscNode'].type = @instruments[@currentInstrument]['oscTypes'][child.shape]
    child.peepObj['oscNode'].frequency.value = 0
    child.peepObj['oscNode'].connect(child.peepObj['gainNode'])
    child.peepObj['oscNode'].noteOn(0)

  setInstrument: (instrument) ->
    if instrument in _.keys @instruments
      @currentInstrument = instrument
      _.each @ba.group.children, (subGroup) =>
        _.each subGroup.children, (child) =>      
          child.peepObj['oscNode'].type = @instruments[@currentInstrument]['oscTypes'][child.shape]

  updateGain: (child) ->

    if child.shape == 'square'
      gainMul = 0.5

    if child.shape == 'circle'
      gainMul = 1

    child.peepObj['gainVal'] = ((10+child.getBoundingClientRect().height)/290)*gainMul

  play: (index) ->
    
    _.each @ba.group.children[index].children, (child) =>
      y = child.translation.y

      # set freq
      child.peepObj['oscNode'].frequency.value = y*2

      # ramp
      now = @context.currentTime
      
      child.peepObj['gainNode'].gain.cancelScheduledValues(now)
      child.peepObj['gainNode'].gain.setValueAtTime(child.peepObj['gainNode'].gain.value, now)
      child.peepObj['gainNode'].gain.linearRampToValueAtTime(child.peepObj['gainVal'], now + @instruments[@currentInstrument]['ramps']['in'])
      #child.peepObj['gainNode'].gain.setValueAtTime(child.peepObj['gainNode'].gain.value, now)
      child.peepObj['gainNode'].gain.linearRampToValueAtTime(0, now + @instruments[@currentInstrument]['dur'])


  initEffects: ->

    @tuna = new Tuna(@context)
    @effects = {}
    
    @effects['delay'] = new @tuna.Delay(
      feedback: 0.5
      delayTime: 500
      wetLevel: 0.2
      dryLevel: 0.2
      bypass: false
    )

    _.each @effects, (effect) =>
      console.log('Connect effect')
      @inNode.connect(effect.input)
      effect.connect(@outGainNode)

$(document).ready ->
  Tity.Peep = new Peep()
