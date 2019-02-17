//
//  main.swift
//  BTServerListener
//
//  Created by Xiang Zhang on 2/15/19.
//  Copyright © 2019 Xiang Zhang. All rights reserved.
//

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

print("Service \(serviceRecord?.getServiceName()!) started")

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
        }
    }
    
    // RFCOMM Channel delegate
    // Receive data
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        let message = String(bytesNoCopy: dataPointer, length: Int(dataLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        print("message: \(message)")
        // Keynote next slide
        if (message != nil) {
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = ["/Users/xzhang1/src/GGTeleprompter/keynoteRemote.scpt", message!]
            task.launch()
        }
    }
}
var btlistener = BTListener()
incomingRFCOMMChannelNotification = IOBluetoothRFCOMMChannel.register(forChannelOpenNotifications: btlistener, selector: #selector(BTListener.newRFCOMMChannelOpened(_:channel:)))

RunLoop.main.run()
