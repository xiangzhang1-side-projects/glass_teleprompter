# python3.3.socket textbook

Pybluez supports RFCOMM. [1][1]

Server
```js
import socket

hostMACAddress = '00:1f:e1:dd:08:3d' # The MAC address of a Bluetooth adapter on the server. The server might have multiple Bluetooth adapters.
port = 3 # 3 is an arbitrary choice. However, it must match the port used by the client.
backlog = 1
size = 1024
s = socket.socket(socket.AF_BLUETOOTH, socket.SOCK_STREAM, socket.BTPROTO_RFCOMM)
s.bind((hostMACAddress,port))
s.listen(backlog)
try:
	client, address = s.accept()
	while 1:
		data = client.recv(size)
		if data:
			print(data)
			client.send(data)
except:	
	print("Closing socket")	
	client.close()
	s.close()
```

Client
```bash
import socket

serverMACAddress = '00:1f:e1:dd:08:3d'
port = 3
s = socket.socket(socket.AF_BLUETOOTH, socket.SOCK_STREAM, socket.BTPROTO_RFCOMM)
s.connect((serverMACAddress,port))
while 1:
	text = input()
	if text == "quit":
		break
	s.send(bytes(text, 'UTF-8'))
s.close()
```

[1]:	http://blog.kevindoran.co/bluetooth-programming-with-python-3/