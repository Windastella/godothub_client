extends Node

onready var conn = GodotHub.new()

func _ready():
	set_process(true)
	
	conn.connect("error",self,"_on_error")
	conn.connect("connected",self,"_on_connected")
	conn.connect("message",self,"_on_receive")
	conn.connect("join",self,"_on_join")
	conn.connect("left",self,"_on_left")
	conn.connect("ping",self,"_on_ping")
	
func _process(dt):
	conn.is_listening()
		
	if Input.is_action_pressed("ui_accept"):
		conn.ping()
		
func _on_error(err):
	print("Error: ",err)
	
func _on_connected():
	print("Connected to server")
	
func _on_join(data):
	print(data.msg)
	
func _on_left(data):
	print(data.msg)
	
func _on_ping(ping):
	print("Ping: ",ping)
	
func _on_receive(data):
	print("Receive Data: ",data)
	
func _exit_tree():
	conn.gd_disconnect()