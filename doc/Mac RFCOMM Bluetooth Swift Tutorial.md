# Mac RFCOMM Bluetooth Swift Tutorial

# RFCOMM

Minimal documentation; scattered online code samples for reverse-engineering.

Import
```swift
import Foundation
import IOBluetooth
import IOBluetoothUI
```

Scan for paired devices
```swift
print("Bluetooth devices:")
guard let devices = IOBluetoothDevice.pairedDevices() else {
	print("No devices")
	return
}
for item in devices {
	if let device = item as? IOBluetoothDevice {
		print("Name: \(device.name)")
		print("AddressString: \(device.addressString)")
		print("Paired?: \(device.isPaired())")
		print("Connected?: \(device.isConnected())")
	}
}
```

Scan nearby BT device
```swift
class BlueDelegate : IOBluetoothDeviceInquiryDelegate {
	func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry) {
		print("deviceInquiryStarted")
	}
	func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry, device: IOBluetoothDevice) {
		print("deviceInquiryDeviceFound \(device.addressString!)")
	}
	func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
		print("deviceInquiryComplete")
	}
}

var delegate = BlueDelegate()
var ibdi = IOBluetoothDeviceInquiry(delegate: delegate)
ibdi!.updateNewDeviceNames = true	// ibdi is optional. ! to force non-nil.
ibdi!.start()

RunLoop.main.run()
```

"Wait" for async listeners indefinitely
```swift
RunLoop.main.run()
```

Client-Listener [Source][1]
```swift
import Cocoa
import IOBluetooth
import IOBluetoothUI
        
// # Find (construct) device by macADDR

// in: uuidStringValue out: sppServiceUUID. same thing, a fuck ton of typecasting.
let uuidStringValue = "e11c6340-2ffd-11e9-b210-d663bd873d93"
let nsuuid = NSUUID(uuidString: uuidStringValue)
let uuidBytePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
nsuuid!.getBytes(uuidBytePointer)
let uuidNSData = NSData(bytes: uuidBytePointer, length: 16)
let sppServiceUUID = IOBluetoothSDPUUID(data: uuidNSData as Data)

var macaddr = "38-80-DF-89-27-12"
let device = IOBluetoothDevice(addressString: macaddr)
print("device \(macaddr) found")

// # Open RFCOMM Channel (as client)

// macOS.API seeks to package things. Instead of server-client, we see "connect to a device". Unfortunately, this makes fine control difficult, especially as documentation is scant.
// a non-RFCOMM service on the server tells all other devices which RFCOMM channel to con to
var sppServiceRecord = device?.getServiceRecord(for: sppServiceUUID)
// WARNING: even if server app is uninstalled, a LEFTOVER will result in a successful connection.
print("service record retrieved")

// ask service for RFCOMM channel ID to open on the device:
var rfcommChannelID: BluetoothRFCOMMChannelID = 0;
sppServiceRecord?.getRFCOMMChannelID(&rfcommChannelID)
print("channel \(rfcommChannelID) identified") 
// WARNING: a channel WILL be opened, even if UUID is faulty.
// INFO: if unpaired, a "pair" dialog appears

// Open asyncronously the rfcomm channel
// When all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
class DataListener: IOBluetoothRFCOMMChannelDelegate{
    // # receive message
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        
        let message = String(bytesNoCopy: dataPointer, length: Int(dataLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        
        print(message)
    }
}

var mDataListener = DataListener()
var mRFCOMMChannel: IOBluetoothRFCOMMChannel?
device?.openRFCOMMChannelSync(&mRFCOMMChannel, withChannelID: BluetoothRFCOMMChannelID(rfcommChannelID), delegate: mDataListener)

print("channel \(mRFCOMMChannel) opened, listening for messages")
RunLoop.main.run()
```
Writer
```swift
func sendMessage(message:String) {
    let data = message.data(using: String.Encoding.utf8)
    let length = data!.count
    let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)

    data?.copyBytes(to: dataPointer,count: length)

    print("Sending Message\n")
    mRFCOMMChannel?.writeSync(dataPointer, length: UInt16(length))
}
```

Server-Listener [Source][2]
About accessing plist from CLI app: add file, new group; build phases -\> copy file -\> product directory -\> subdirectory .
```swift
import Cocoa
import IOBluetooth
import IOBluetoothUI

var rfcommChannelID: BluetoothRFCOMMChannelID = 0
var sdpServiceRecordHandle: BluetoothSDPServiceRecordHandle = 0
var incomingRFCOMMChannelNotification: IOBluetoothUserNotification?
var currentRFCOMMChannel: IOBluetoothRFCOMMChannel?

// Load SDP config dictionary
let dictionaryPath = Bundle.main.path(forResource: "SerialPortDict", ofType: "plist")
var sdpEntries = NSDictionary(contentsOfFile: dictionaryPath!)

// Publish SDP service
let serviceRecord = IOBluetoothSDPServiceRecord.publishedServiceRecord(with: sdpEntries as! [AnyHashable : Any]) as? IOBluetoothSDPServiceRecord

var res: IOReturn? = serviceRecord?.getRFCOMMChannelID(&rfcommChannelID)
if res != kIOReturnSuccess {
    print("getRFCOMMChannelID failed: %@", NSNumber(value: res!))
    exit(0)
}
res = serviceRecord?.getHandle(&sdpServiceRecordHandle)
if res != kIOReturnSuccess {
    print("getServiceRecordHandle failed: %@", NSNumber(value: res!))
    exit(0)
}

print("Service Name is %@. Details:", serviceRecord?.getServiceName())
print("-----------------------------")
print(serviceRecord)
print("-----------------------------")

// Register a notification so we get notified when an incoming RFCOMM channel is opened
// to the channel assigned to our chat service.
class BTListener: IOBluetoothRFCOMMChannelDelegate {
    // MARK: - RFCOMM open notification
    // Listen to channel open notification
    @objc func newRFCOMMChannelOpened(_ inNotification: IOBluetoothUserNotification?, channel newChannel: IOBluetoothRFCOMMChannel?) {
        if inNotification?.isEqual(incomingRFCOMMChannelNotification) ?? false {
            print("Channel opened")
            newChannel?.setDelegate(self)
            currentRFCOMMChannel = newChannel
        } else {
            print("Not our business")
        }
    }
    
    // RFCOMM Channel delegate
    // Receive data
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        let message = String(bytesNoCopy: dataPointer, length: Int(dataLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        print(message)
    }
}
var btlistener = BTListener()
incomingRFCOMMChannelNotification = IOBluetoothRFCOMMChannel.register(forChannelOpenNotifications: btlistener, selector: #selector(BTListener.newRFCOMMChannelOpened(_:channel:)))

RunLoop.main.run()
```
SerialPortDict.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>0000 - ServiceRecordHandle*</key>
	<integer>65540</integer>
	<key>0001 - ServiceClassIDList</key>
	<array>
		<data>AAARAQAAEACAAACAX5s0+w==</data>
	</array>
	<key>0004 - ProtocolDescriptorList</key>
	<array>
		<array>
			<data>AQA=</data>
		</array>
		<array>
			<data>AAM=</data>
			<dict>
				<key>DataElementSize</key>
				<integer>1</integer>
				<key>DataElementType</key>
				<integer>1</integer>
				<key>DataElementValue</key>
				<integer>3</integer>
			</dict>
		</array>
	</array>
	<key>0005 - BrowseGroupList*</key>
	<array>
		<data>EAI=</data>
	</array>
	<key>0006 - LanguageBaseAttributeIDList*</key>
	<array>
		<dict>
			<key>DataElementSize</key>
			<integer>2</integer>
			<key>DataElementType</key>
			<integer>1</integer>
			<key>DataElementValue</key>
			<integer>25966</integer>
		</dict>
		<dict>
			<key>DataElementSize</key>
			<integer>2</integer>
			<key>DataElementType</key>
			<integer>1</integer>
			<key>DataElementValue</key>
			<integer>106</integer>
		</dict>
		<dict>
			<key>DataElementSize</key>
			<integer>2</integer>
			<key>DataElementType</key>
			<integer>1</integer>
			<key>DataElementValue</key>
			<integer>256</integer>
		</dict>
	</array>
	<key>0009 - BluetoothProfileDescriptorList</key>
	<array>
		<array>
			<data>AAARAQAAEACAAACAX5s0+w==</data>
			<dict>
				<key>DataElementSize</key>
				<integer>2</integer>
				<key>DataElementType</key>
				<integer>1</integer>
				<key>DataElementValue</key>
				<integer>256</integer>
			</dict>
		</array>
	</array>
	<key>0100 - ServiceName*</key>
	<string>XD_RFCOMM</string>
	<key>0303 - Supported Formats List</key>
	<array>
		<dict>
			<key>DataElementType</key>
			<integer>1</integer>
			<key>DataElementValue</key>
			<data>/w==</data>
		</dict>
	</array>
</dict>
</plist>

```

# BLE
Definition: characteristic-description over GATT/ATT [2][3]
Android Java Server: Advertise -\> GATT server [1][4]  [3][5]
macOS Swift Client: Scan -\> GATT client [4][6]

[1]:	https://github.com/garvincasimir/coco-bluetooth-rfcomm-swift/blob/master/Cocoa%20Bluetooth%20RFCOMM%20Swift/AppDelegate.swift
[2]:	https://github.com/RomainQuidet/rfcommServer
[3]:	https://developer.android.com/guide/topics/connectivity/bluetooth-le
[4]:	hub.com/androidthings/sample-bluetooth-le-gattserver/blob/master/java/app/src/main/java/com/example/androidthings/gattserver/GattServerActivity.java
[5]:	https://code.tutsplus.com/tutorials/how-to-advertise-android-as-a-bluetooth-le-peripheral--cms-25426
[6]:	https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor