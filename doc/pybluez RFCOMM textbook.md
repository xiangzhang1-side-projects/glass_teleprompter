# pybluez RFCOMM textbook

[source][1]
Module `bluetooth`

# Finding device (mostly, find MAC addr) on both sides

Method `discover_devices()`
returns `[str]`: a list of MAC addresses
comment: supports Android.Settings.makediscoverable, GoogleGlass… , iOS…, 

You do not need to make device discoverable per-se. All that you need is i) bluetooth is on, ii) MAC address.

# Server

```python
# create socket

server_sock = bluetooth.BluetoothSocket( bluetooth.RFCOMM )
server_sock.bind(("", port)) # port = 0
server_sock.listen(1)

# connect

client_sock, client_info = server_sock.accept()
print "Accepted connection from ", client_info

# receive data

data = client_sock.recv(1024)
print "received [%s]" % data
client_sock.close()
server_sock.close()
```

# Client

```python
# create socket

server_address = "01:23:45:67:89:AB"
sock = bluetooth.BluetoothSocket( RFCOMM )

# connect

sock.connect((server_address, port)) # port = 1

# send data
sock.send("hello!!")
sock.close()
```

[1]:	http://people.csail.mit.edu/rudolph/Teaching/Articles/BTBook.pdf