# GodotHub Client Class
# Author: Nik Mirza
# Email: nik96mirza[at]gmail.com

signal error(err) # Declare signals
signal listening
signal connected
signal join(id)
signal left(id)
signal message(data)
signal ping(ping)

var conn

var server = {
	port = 5000,
	host = '127.0.0.1',
}

var client = {
	ID = "",
	channel = 'global'
}

func _init(serverport = 5000, serverhost = '127.0.0.1', serverchannel= "global", listenport = 4000):
	server.host = serverhost
	server.port = serverport
	client.channel = serverchannel
	
	conn = PacketPeerUDP.new()
	var err = conn.listen(listenport)
	if err:
		emit_signal("error", err)
	
	conn.set_send_address(server.host,server.port)
	send_data({event="connecting"})
	
func is_listening(dt):
	if !conn.is_listening():
		return false
	
	if data_available():
		var data = get_data()
		
		if data.event == "connected":
			emit_signal("connected")
			client.ID = data.ID
			return
			
		if data.event == "join":
			emit_signal("join", data.ID)#join signal when data is received
			return
			
		if data.event == "left":
			emit_signal("left", data.ID)#join signal when data is received
			return
			
		if data.event == "ping":
			var ping = clamp((dt - data.data)*1000, 0, 10000)
			ping = round(ping)
			emit_signal("ping",ping)
			return 
		emit_signal("message",data)#message signal when data is received
		
func change_channel(channel):
	client.channel = channel
	send_data({event="channel"})
	
func ping(dt):
	send_data({event="ping", data=dt})
	
func data_available():
	if conn.get_available_packet_count() > 0:
		return true
	return false
	
func get_data():#As dictionary
	var data = conn.get_var()
	var dict = {}
	dict.parse_json(data)
	return dict
	
func broadcast_data(data): #Only accept dictionary
	var dat = {event="broadcast"}
	dat.data = data
	send_data(dat)
	
func multicast_data(data): #Only accept dictionary
	var dat = {event="multicast"}
	dat.data = data
	send_data(dat)
	
func unicast_data(data, clientID): #Only accept dictionary
	var dat = {event="unicast"}
	dat.data = data
	dat.ID = clientID
	send_data(dat)
	
func send_data(data): #Only accept dictionary
	client.data = data
	conn.put_var(client.to_json())
		
func disconnect():
	send_data({event="disconnect"})
	conn.close()