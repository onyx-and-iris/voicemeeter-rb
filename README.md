[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/onyx-and-iris/voicemeeter-rb/blob/dev/LICENSE)
[![Ruby Code Style](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)

# Ruby Wrapper for Voicemeeter API

This gem offers a Ruby interface for the Voicemeeter Remote C API.

For an outline of past/future changes refer to: [CHANGELOG](CHANGELOG.md)

## Tested against

- Basic 1.0.8.8
- Banana 2.0.6.8
- Potato 3.0.2.8

## Requirements

- [Voicemeeter](https://voicemeeter.com/)
- Ruby 3.2 or greater

## Installation

### Bundler

```
bundle add 'voicemeeter'
bundle install
```

### Gem

`gem install 'voicemeeter'`

## `Use`

Simplest use case, request a Remote class of a kind, then pass a block to run.

Login and logout are handled for you in this scenario.

#### `main.rb`

```ruby
require "voicemeeter"

vm = Voicemeeter.remote(:banana)

# vm.run accepts a block
vm.run do
  # mute the leftmost strip
  vm.strip[0].mute = true
  puts vm.strip[0].mute

  # disable eq for second from left bus
  vm.bus[1].eq = false
  puts vm.bus[1].eq
end
```

Otherwise you must remember to call `vm.login` `vm.logout` at the start/end of your code.

## `kind_id`

Pass the kind of Voicemeeter as an argument. kind_id may be:

- `:basic`
- `:banana`
- `:potato`

## `Available commands`

### Strip

The following properties are available.

- `mono`: boolean
- `solo`: boolean
- `mute`: boolean
- `gain`: float, from -60.0 to 12.0
- `comp`: float, from 0.0 to 10.0
- `gate`: float, from 0.0 to 10.0
- `audibility`: float, from 0.0 to 10.0
- `limit`: int, from -40 to 12
- `A1 - A5`, `B1 - B3`: boolean
- `label`: string
- `mc`: boolean
- `k`: int, from 0 to 4
- `bass`: float, from -12.0 to 12.0
- `mid`: float, from -12.0 to 12.0
- `treble`: float, from -12.0 to 12.0
- `reverb`: float, from 0.0 to 10.0
- `delay`: float, from 0.0 to 10.0
- `fx1`: float, from 0.0 to 10.0
- `fx2`: float, from 0.0 to 10.0
- `pan_x`: float, from -0.5 to 0.5
- `pan_y`: float, from 0.0 to 1.0
- `color_x`: float, from -0.5 to 0.5
- `color_y`: float, from 0.0 to 1.0
- `fx_x`: float, from -0.5 to 0.5
- `fx_y`: float, from 0.0 to 1.0
- `postreverb`: boolean
- `postdelay`: boolean
- `postfx1`: boolean
- `postfx2`: boolean

example:

```ruby
vm.strip[3].gain = 3.7
puts vm.strip[0].label
```

The following methods are available.

- `appgain(name, value)`: string, float, from 0.0 to 1.0

Set the gain in db by value for the app matching name.

- `appmute(name, value)`: string, bool

Set mute state as value for the app matching name.

example:

```ruby
vm.strip[5].appgain("Spotify", 0.5)
vm.strip[5].appmute("Spotify", true)
```

##### Gainlayers

- `gain`: float, from -60.0 to 12.0

example:

```ruby
vm.strip[3].gainlayer[3].gain = 3.7
```

Gainlayers are defined for potato version only.

##### Levels

The following properties are available.

- `prefader`
- `postfader`
- `postmute`

example:

```ruby
puts vm.strip[3].levels.prefader
```

Level properties will return -200.0 if no audio detected.

### Bus

The following properties are available.

- `mono`: boolean
- `mute`: boolean
- `eq`: boolean
- `eq_ab`: boolean
- `sel`: boolean
- `gain`: float, from -60.0 to 12.0
- `label`: string
- `returnreverb`: float, from 0.0 to 10.0
- `returndelay`: float, from 0.0 to 10.0
- `returnfx1`: float, from 0.0 to 10.0
- `returnfx2`: float, from 0.0 to 10.0
- `monitor`: boolean

example:

```ruby
vm.bus[3].gain = 3.7
puts vm.bus[0].label

vm.bus[4].mono = true
```

##### Modes

- `normal`: boolean
- `amix`: boolean
- `bmix`: boolean
- `composite`: boolean
- `tvmix`: boolean
- `upmix21`: boolean
- `upmix41`: boolean
- `upmix61`: boolean
- `centeronly`: boolean
- `lfeonly`: boolean
- `rearonly`: boolean

example:

```ruby
vm.bus[4].mode.amix = true
```

##### Levels

The following properties are available.

- `all`

example:

```ruby
puts vm.bus[0].levels.all
```

`levels.all` will return -200.0 if no audio detected.

### Strip | Bus

The following methods are available

- `fadeto(amount, time)`: float, int
- `fadeby(amount, time)`: float, int

Modify gain to or by the selected amount in db over a time interval in ms.

example:

```ruby
vm.strip[0].fadeto(-10.3, 1000)
vm.bus[3].fadeby(-5.6, 500)
```

#### Strip.Device | Bus.Device

The following properties are available

- `name`: str
- `sr`: int
- `wdm`: str
- `ks`: str
- `mme`: str
- `asio`: str

example:

```ruby
puts vm.strip[0].device.name
vm.bus[0].device.asio = "Audient USB Audio ASIO Driver"
```

strip|bus device parameters are defined for physical channels only.

name, sr are read only. wdm, ks, mme, asio are write only.

### Macrobuttons

Three modes defined: state, stateonly and trigger.

- `state`: boolean
- `stateonly`: boolean
- `trigger`: boolean

example:

```ruby
vm.button[37].state = true
vm.button[55].trigger = false
```

### Recorder

The following properties accept boolean values.

- `loop`: boolean
- `A1 - A5`: boolean
- `B1 - A3`: boolean

The following methods are available

- `play`
- `stop`
- `pause`
- `record`
- `ff`
- `rew`
- `load(filepath)`: string

example:

```ruby
vm.recorder.play
vm.recorder.stop

# Enable loop play
vm.recorder.loop = true

# Disable recorder out channel B2
vm.recorder.B2 = false

# filepath as string
vm.recorder.load('C:\music\mytune.mp3')
```

### VBAN

- `vm.vban.enable` `vm.vban.disable` Turn VBAN on or off

##### Instream | Outstream

The following properties are available.

- `on`: boolean
- `name`: string
- `ip`: string
- `port`: int, range from 1024 to 65535
- `sr`: int, (11025, 16000, 22050, 24000, 32000, 44100, 48000, 64000, 88200, 96000)
- `channel`: int, from 1 to 8
- `bit`: int, 16 or 24
- `quality`: int, from 0 to 4
- `route`: int, from 0 to 8

SR, channel and bit are defined as readonly for instreams. Attempting to write to those parameters will throw an error. They are read and write for outstreams.

example:

```ruby
# turn VBAN on
vm.vban.enable

# turn on vban instream 0
vm.vban.instream[0].on = true

# set bit property for outstream 3 to 24
vm.vban.outstream[3].bit = 24
```

### Command

Certain 'special' commands are defined by the API as performing actions rather than setting values. The following methods are available:

- `show` : Bring Voiceemeter GUI to the front
- `shutdown` : Shuts down the GUI
- `restart` : Restart the audio engine

The following properties are write only and accept boolean values.

- `showvbanchat`: boolean
- `lock`: boolean

example:

```ruby
vm.command.restart
vm.command.showvbanchat = true
```

### Device

- `ins` `outs` : Returns the number of input/output devices
- `input(i)` `output(i)` : Returns a hash of device properties for device[i]

example:

```ruby
vm.run { (0...vm.device.ins).each { |i| puts vm.device.input(i) } }
```

### Midi

The following properties are available:

- `channel`: int, returns the midi channel
- `current`: int, returns the current (or most recently pressed) key

The following methods are available:

- `get(key)`: int, returns most recent velocity value for a key

example:

```ruby
puts vm.midi.get(12)
```

get may return nil if no value for requested key in midi cache

### Multiple parameters

- `apply`
  Set many strip/bus/macrobutton/vban parameters at once, for example:

```ruby
vm.apply(
  {
    strip_0: {
      mute: true,
      gain: 3.2,
      A1: true
    },
    bus_3: {
      gain: -3.2,
      eq: true
    },
    button_39: {
      stateonly: true
    },
    vban_outstream_3: {
      on: true,
      bit: 24
    }
  }
)
```

Or for each class you may do:

```ruby
vm.strip[0].apply(mute: true, gain: 3.2, A1: true)
vm.vban.outstream[0].apply(on: true, name: "streamname", bit: 24)
```

## Config Files

`vm.apply_config(<configname>)`

You may load config files in TOML format.
Three example configs have been included with the package. Remember to save
current settings before loading a config. To set one you may do:

```ruby
require "voicemeeter"
vm = Voicemeeter.remote(:banana)
vm.run { vm.apply_config(:example) }
```

will load a config file at mydir/configs/banana/example.toml for Voicemeeter Banana.

## Events

By default, NO events listened for.

Use keyword args `pdirty`, `mdirty`, `midi`, `ldirty` to initialize event updates.

example:

```ruby
require 'voicemeeter'
# Set updates to occur every 50ms
# Listen for level updates
vm = Voicemeeter.remote('banana', ratelimit: 0.05, ldirty: true)
vm.run { ... }
```

#### `vm.register`|`vm.deregister`

Use the register/deregister methods to register/deregister callbacks and event observers.

example:

```ruby
# register an app to receive updates
class App():
    def initialize(vm)
        @vm = vm
        @vm.register(method(:on_pdirty))
        ...

    def on_pdirty
        ...
```

#### `vm.event`

Use the event class to toggle updates as necessary.

The following properties are available:

- `pdirty`: boolean
- `mdirty`: boolean
- `midi`: boolean
- `ldirty`: boolean

example:

```ruby
vm.event.ldirty = true

vm.event.pdirty = false
```

Or add, remove an array of events.

The following methods are available:

- `add(events)`
- `remove(events)`
- `get`

example:

```ruby
vm.event.add(%w[pdirty mdirty midi ldirty])

vm.event.remove(%w[pdirty mdirty midi ldirty])

# get a list of currently subscribed
p vm.event.get
```

## `Voicemeeter Module`

### Remote class

#### Voicemeeter.remote

You may pass the following optional keyword arguments:

- `sync`: boolean=false, force the getters to wait for dirty parameters to clear. For most cases leave this as false.
- `ratelimit`: float=0.033, how often to check for updates in ms.
- `pdirty`: boolean=true, parameter updates
- `mdirty`: boolean=true, macrobutton updates
- `midi`: boolean=true, midi updates
- `ldirty`: boolean=false, level updates

Access to lower level Getters and Setters are provided with these functions:

- `vm.get(param, string=false)`: For getting the value of any parameter. Set string to true if getting a property value expected to return a string.
- `vm.set(param, value)`: For setting the value of any parameter.

Access to lower level polling functions are provided with these functions:

- `vm.pdirty?`: Returns true iff a parameter has been updated.
- `vm.mdirty?`: Returns true iff a macrobutton has been updated.

example:

```ruby
vm.get("Strip[2].Mute")
vm.set("Strip[4].Label", "stripname")
vm.set("Strip[0].Gain", -3.6)
```

### Run tests

To run all tests:

```
Bundle exec rspec
```

You can use tags to run only certain tests, for example:

```
Bundle exec rspec --tag 'higher'
```

### Official Documentation

- [Voicemeeter Remote C API](https://github.com/onyx-and-iris/Voicemeeter-SDK/blob/main/VoicemeeterRemoteAPI.pdf)
