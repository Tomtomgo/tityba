class Titypeep

  instruments:
    'brom': {ramps: {in:0.01, out:0.01}, osc1Type: 0, osc2Type: 2, mod: 0.2}
    'blar': {ramps: {in:0.1, out:0.01}, osc1Type: 1, osc2Type: 1, mod: 0}
    'piip': {ramps: {in:0.8, out:1}, osc1Type: 3, osc2Type: 2, mod: 5} 
    'bumm': {ramps: {in:0.1, out:0.1}, osc1Type: 0, osc2Type: 0, mod: 0} 

  currentInstrument: 'brom'

  initPeeps: (group, speed) ->
    console.log("initPeeps")
    @group = group
    @speed = speed

    @context = new webkitAudioContext()
    
    @initOutput() # Connect the output

    @initGenerators() # Init and connect the generators

  initOutput: ->
    @outGainNode = @context.createGainNode()
    @outGainNode.gain.value = 0.7
    @outGainNode.connect(@context.destination)

  initGenerators: ->

    @oscs = {}

    _.each @group.children, (child) =>
      @oscs[child.id] = {}

      @oscs[child.id]['gainVal'] = ((10+child.getBoundingClientRect().height)/290)

      @oscs[child.id]['gainNode'] = @context.createGainNode()
      @oscs[child.id]['gainNode'].gain.value = 0
      @oscs[child.id]['gainNode'].connect(@outGainNode)
      
      @oscs[child.id]['oscNode'] = @context.createOscillator()
      @oscs[child.id]['oscNode'].type = 0
      @oscs[child.id]['oscNode'].frequency.value = 0
      @oscs[child.id]['oscNode'].connect(@oscs[child.id]['gainNode'])
      @oscs[child.id]['oscNode'].noteOn(0)

  addGenerator: (child) ->

    if child.shape == 'square'
      oscType = 2
      gainMul = 0.5

    if child.shape == 'circle'
      oscType = 0
      gainMul = 1

    @oscs[child.id] = {}

    @oscs[child.id]['gainVal'] = ((10+child.getBoundingClientRect().height)/290)

    @oscs[child.id]['gainNode'] = @context.createGainNode()
    @oscs[child.id]['gainNode'].gain.value = @oscs[child.id]['gainVal']*gainMul
    @oscs[child.id]['gainNode'].connect(@outGainNode)
    
    @oscs[child.id]['oscNode'] = @context.createOscillator()
    @oscs[child.id]['oscNode'].type = oscType
    @oscs[child.id]['oscNode'].frequency.value = 0
    @oscs[child.id]['oscNode'].connect(@oscs[child.id]['gainNode'])
    @oscs[child.id]['oscNode'].noteOn(0)

    console.log(@oscs)

  destroyGenerator: (id) ->
    delete @oscs[id]

  updateGain: (child) ->

    if child.shape == 'square'
      gainMul = 0.5

    if child.shape == 'circle'
      gainMul = 1

    @oscs[child.id]['gainVal'] = ((10+child.getBoundingClientRect().height)/290)*gainMul

  play: (index) ->
    child = @group.children[index]

    y = child.translation.y

    # set freq
    @oscs[index]['oscNode'].frequency.value = y*2

    # ramp
    now = @context.currentTime
    
    @oscs[index]['gainNode'].gain.cancelScheduledValues(now)
    @oscs[index]['gainNode'].gain.setValueAtTime(@oscs[index]['gainNode'].gain.value, now)
    @oscs[index]['gainNode'].gain.linearRampToValueAtTime(@oscs[index]['gainVal'], now + @instruments[@currentInstrument]['ramps']['in'])
    #@oscs[child.id]['gainNode'].gain.setValueAtTime(@oscs[child.id]['gainNode'].gain.value, now)
    @oscs[index]['gainNode'].gain.linearRampToValueAtTime(0, now + 1)


  initEffects: ->

    if not @source
      return "Oh no!"

    @tuna = new Tuna(@context)

    @effects['overdrive'] = new @tuna.Overdrive(
      outputGain: 0.3
      drive: 0.5
      curveAmount: 0.4
      algorithmIndex: 2
      bypass: true
    )

    @effects['delay'] = new @tuna.Delay(
      feedback: 0
      delayTime: 250
      wetLevel: 1
      dryLevel: 1
      bypass: true
    )

    @effects['chorus'] = new @tuna.Chorus(
      feedback: 0.5
      rate: 1.5
      delay: 0.005
      bypass: true
    )

    @effects['tremolo'] = new @tuna.Tremolo(
        intensity: 0.3    # 0 to 1
        rate: 0.1         # 0.001 to 8
        stereoPhase: 0    # 0 to 180
        bypass: false
    )

    _.each @effects, (effect) =>
      @source.connect(effect.input)
      effect.connect(@sourceGainNode)

  silenceEffects: ->
    for effect in @effects
      effect.bypass = true

  setEffect: (effectName, v1, v2) ->
    
    @silenceEffects()

    if effectName is 'overdrive'
      @effects[effectName].bypass = false
      @effects[effectName].drive = v1
      @effects[effectName].curveAmount = v2

    if effectName is 'delay'
      @effects[effectName].bypass = false
      @effects[effectName].feedback = v1
      @effects[effectName].delayTime = v2*1000

    if effectName is 'chorus'
      @effects[effectName].bypass = false
      @effects[effectName].rate = v1*20
      @effects[effectName].feedback = Math.min(v2, 0.95)

    if effectName is 'tremolo'
      @effects[effectName].bypass = false
      @effects[effectName].rate = v1*8
      @effects[effectName].intensity = v2

$(document).ready ->
  window.ttp = new Titypeep()
