# Android SDK bluetooth Textbook
[1][1][unimportant actual app][2]

## Permisssions.
```js
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Also this must be run at runtime (for Android4.4+ only):
```js
ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, 1);
```

## Enable bluetooth
```js
BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter(); 
```

Query paired devices
```js
Set<BluetoothDevice> pairedDevices = bluetoothAdapter.getBondedDevices();

if (pairedDevices.size() > 0) {
	// There are paired devices. Get the name and address of each paired device.
	for (BluetoothDevice device : pairedDevices) {
		String deviceName = device.getName();
		String deviceHardwareAddress = device.getAddress(); // MAC address
	}
}
```

## Get device (discover)

Server: makes itself discoverable (or use system’s UI)
```js
Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
startActivity(discoverableIntent);
```

Client: searches
```js
@Override
protected void onCreate(Bundle savedInstanceState) {
	...

	// Register for broadcasts when a device is discovered.
	IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
	registerReceiver(receiver, filter);

	bluetoothAdapter.startDiscovery();

}
```

```js
private final BroadcastReceiver receiver = new BroadcastReceiver() {
	  public void onReceive(Context context, Intent intent) {
	  	  if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
	  	  	  // Discovery found a device. Get the BluetoothDevice object and its info from the Intent.
	  	  	  BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
	  	  	  String deviceName = device.getName();
	  	  	  String deviceHardwareAddress = device.getAddress(); // MAC address
	  	  }
	  }
};
```

## Create socket, connect (UUID-based)

Server
```js
// create socket

UUID myUUID = UUID.fromString("e11c6340-2ffd-11e9-b210-d663bd873d93");

BluetoothServerSocket mmServerSocket = bluetoothAdapter.listenUsingInsecureRfcommWithServiceRecord(NAME, MY_UUID);

// connect

BluetoothSocket mmsocket = mmServerSocket.accept();

// connected, do something

mmServerSocket.close();
```
Including "Insecure" seems to allow connection without pairing. Let’s try. [1][3]

Client
```js
// create socket
UUID myUUID = UUID.fromString("e11c6340-2ffd-11e9-b210-d663bd873d93");

BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(MACaddr);

BluetoothSocket mmSocket = device.createInsecureRfcommSocketToServiceRecord()); // hard-code UUID

// connect

mmSocket.connect();

mmSocket.close();
```

## Streaming data
```js
// read
InputStream mmInStream = mmSocket.getInputStream();
byte[] mmBuffer = new byte[1024];
int numBytes = mmInStream.read(mmBuffer);
String message = new String(mmBuffer);

//write
OutputStream mmOutStream = mmSocket.getOutputStream();
mmOutStream.write("someText".getBytes());
```


[1]:	https://developer.android.com/guide/topics/connectivity/bluetooth
[2]:	https://code.tutsplus.com/tutorials/create-a-bluetooth-scanner-with-androids-bluetooth-api--cms-24084
[3]:	https://stackoverflow.com/questions/35953413/bluetooth-connect-without-pairing