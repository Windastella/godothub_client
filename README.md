# Godot GodotHub Class API

Multiplayer and network messaging Server for Godot.

The Godot Client code are in written as class which can be instanced through script.

The main idea of GodotHub is to have a thin server that only handle the connection and broadcast the data to channel(lobby).

[GodotHub](https://github.com/Windastella/godothub) : GodotHub NodeJS Server

## Implementation

The class for the client is in scripts/godothub.gd . Copy and load it into your game through script.


```
extends Node

onready var godothub = preload('scripts/godothub.gd')
onready var conn = godothub.new()

func _ready():
	set_process(true)

  # Connect to message signal of godothub to callback
	conn.connect("message",self,"_on_receive")

func _process(dt):

  # Listening for packet
	conn.is_listening()

# Callback for receiving incoming packet
func _on_receive(data):
	print("Receive Data: ",data)

```

## API

### Methods

#### .new

` var obj = godothub.new( serverport, serverhost, channel, clientport) `

Initialize the godothub object.

`serverport` Port of the Server. Default: 5000

`serverhost` Host Address of Server. Default: localhost

`channel` Initial Lobby or Room. Default: global

`clientport` Client's listen port. Default: 4000

#### .is_listening

` obj.is_listening() `

Listen for packet.

Return: boolean

#### .change_channel

` obj.change_channel(channel) `

Leave current channel and Join new channel. Creating new channel if the channel does not exist yet.

`channel` lobby you are changing to.

#### .send_data

` obj.send_data(data) `

Send data to the server.

`data` The data are formatted into JSON format.

#### .disconnect

` obj.disconnect() `

Disconnect from server.

### Signals

#### error(err)

Triggered when connection return error.

#### listening

Triggered if listen successful.

#### join(id)

Triggered when new client joined the channel.

`id` is the id of the new client.

#### left(id)

Triggered when a client left the channel.

`id` is the id of the leaving client.

#### message(data)

Triggered when a common data arrived.

`data` Data is dictionary.
