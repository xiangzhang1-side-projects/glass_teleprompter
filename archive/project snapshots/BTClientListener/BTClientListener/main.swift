//
//  main.swift
//  BTClientListener
//
//  Created by Xiang Zhang on 2/15/19.
//  Copyright © 2019 Xiang Zhang. All rights reserved.
//

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
print("channel \(rfcommChannelID) identified") // a channel WILL be opened, if UUID is faulty.

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
