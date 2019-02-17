//  Converted to Swift 4 by Swiftify v4.2.34952 - https://objectivec2swift.com/
//
//  AppDelegate.swift
//  Coco Test
//
//  Created by Worker PC on 6/12/13.
//  Copyright (c) 2013 Worker PC. All rights reserved.
//

import Cocoa
import IOBluetooth
import IOBluetoothUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var textView: Any!
    var mRFCOMMChannel: IOBluetoothRFCOMMChannel?

    @IBOutlet var window: NSWindow!

    @IBAction func clearText(_ sender: ) {
        textView.string = " "
    }

    @IBAction func discover(_ sender: Any) {
        var deviceSelector: IOBluetoothDeviceSelectorController?
        var sppServiceUUID: IOBluetoothSDPUUID?
        var deviceArray: [Any]
        var chan: IOBluetoothRFCOMMChannel?

        log("Attempting to connect\n")

        // The device selector will provide UI to the end user to find a remote device
        deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()

        if deviceSelector == nil {
            log("Error - unable to allocate IOBluetoothDeviceSelectorController.\n")
            return
        }

        sppServiceUUID = IOBluetoothSDPUUID.uuid16(kBluetoothSDPUUID16ServiceClassSerialPort)
        if let sppServiceUUID = sppServiceUUID {
            deviceSelector?.addAllowedUUID(sppServiceUUID)
        }
        if Int(deviceSelector?.runModal() ?? 0) != kIOBluetoothUISuccess {
            log("User has cancelled the device selection.\n")
            return
        }
        if let get = deviceSelector?.getResults() {
            deviceArray = get
        }
        if (deviceArray == nil) || (deviceArray.count == 0) {
            log("Error - no selected device.  ***This should never happen.***\n")
            return
        }
        let device = deviceArray[0] as? IOBluetoothDevice
        var sppServiceRecord: IOBluetoothSDPServiceRecord? = nil
        if let sppServiceUUID = sppServiceUUID {
            sppServiceRecord = device?.getServiceRecord(for: sppServiceUUID)
        }
        if sppServiceRecord == nil {
            log("Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n")
            return
        }
        // To connect we need a device to connect and an RFCOMM channel ID to open on the device:
        var rfcommChannelID: UInt8
        if sppServiceRecord?.getRFCOMMChannelID(&rfcommChannelID) != kIOReturnSuccess {
            log("Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n")
            return
        }

        // Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
        if (device?.openRFCOMMChannelAsync(&chan, withChannelID: BluetoothRFCOMMChannelID(rfcommChannelID), delegate: self) != kIOReturnSuccess) && (chan != nil) {
            // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
            // those details). If the device connection is left open close it and return an error:
            log("Error - open sequence failed.***\n")
            close(device)
            return
        }

        mRFCOMMChannel = chan

    }

    @IBAction func hello(_ sender: ) {
        let myString = "I am doing ok Android. Thanks for asking"

        let dt: Data? = myString.data(using: String.Encoding(NSString.defaultCStringEncoding))

        sendMessage(dt)

    }

    func close(_ device: IOBluetoothDevice?) {
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func sendMessage(_ dataToSend: Data?) {
        log("Sending Message\n")
        mRFCOMMChannel?.writeSync(dataToSend?.bytes, length: UInt16((dataToSend?.count ?? 0)))
    }

    func log(_ text: String?) {
        let t = textView.string()

        let new = t + (text ?? "")

        textView.string = new


    }

    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {

        if error != kIOReturnSuccess {
            log("Error - failed to open the RFCOMM channel with error %08lx.\n")

            return
        } else {
            log("Connected\n")
        }

    }

    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {

        var message: String? = nil
        if let dataPointer = dataPointer {
            message = String(bytes: dataPointer, encoding: .utf8)
        }
        log(message)
        log("\n")
    }
}