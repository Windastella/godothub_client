# GodotHub Client Class
# Author: Nik Mirza
# Email: nik96mirza[at]gmail.com
class_name GodotHub

signal error(err) # Declare signals
#signal listening
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
	conn.set_dest_address(server.host,server.port);
	
	var err = conn.listen(listenport)
	if err:
		emit_signal("error", err)
		
	send_data({event="connecting"})
	
func is_listening():
	if !conn.is_listening():
		return false
		
	if data_available():
		var data = get_data()
		
		if data.event == "connected":
			client.ID = data.ID
			emit_signal("connected")
			return
			
		if data.event == "join":
			unicast({event="join",msg=String(client.ID)+" join the channel",ID=client.ID},data.ID)#send join to newly joined client
			emit_signal("join", data)# join signal when data is received
			return
			
		if data.event == "left":
			emit_signal("left", data)#left signal when data is received
			return
			
		if data.event == "ping":
			var ping = OS.get_ticks_msec() - data.data
			ping = round(ping)
			emit_signal("ping",ping)
			return
			
		emit_signal("message",data)#message signal when data is received
		
func change_channel(channel):
	client.channel = channel
	send_data({event="channel"})
	
func ping():
	send_data({event="ping", data=OS.get_ticks_msec()})
	
func data_available():
	return conn.get_available_packet_count() > 0
	
func get_data():#As dictionary
	var data = conn.get_var()
	var dict = {}
	dict = JSON.parse(data).result
	return dict
	
func broadcast(data): #Only accept dictionary
	var dat = {event="broadcast"}
	dat.data = data
	send_data(dat)
	
func multicast(data): #Only accept dictionary
	var dat = {event="multicast"}
	dat.data = data
	send_data(dat)
	
func unicast(data, clientID): #Only accept dictionary
	var dat = {event="unicast"}
	dat.data = data
	dat.ID = clientID
	send_data(dat)
	
func send_data(data): #Only accept dictionary
	client.data = data
	conn.put_var(JSON.print(client))
		
func disconnect_server():
	send_data({event="disconnect"})
	conn.close()