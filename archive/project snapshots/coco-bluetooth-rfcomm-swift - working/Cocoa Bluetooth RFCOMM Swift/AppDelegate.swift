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
class AppDelegate: NSObject, NSApplicationDelegate, IOBluetoothRFCOMMChannelDelegate {
    
    var mRFCOMMChannel: IOBluetoothRFCOMMChannel?
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet var txtvw: NSTextView!
    
    @IBAction func clearText(_ sender: AnyObject) {
        textView.string = " "
    }
    
    @IBAction func discover(_ sender: AnyObject) {
        
        // # Find device
        print("Attempting to connect\n")
        let uuidStringValue = "e11c6340-2ffd-11e9-b210-d663bd873d93"
        let nsuuid = NSUUID(uuidString: uuidStringValue)
        let uuidBytePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        nsuuid!.getBytes(uuidBytePointer)
        let uuidNSData = NSData(bytes: uuidBytePointer, length: 16)
        let sppServiceUUID = IOBluetoothSDPUUID(data: uuidNSData as Data)
        
        // The device selector will provide UI to the end user to find a remote device
        var deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()

        if deviceSelector == nil {
            print("Error - unable to allocate IOBluetoothDeviceSelectorController.\n")
            return
        }

        deviceSelector?.addAllowedUUID(sppServiceUUID)
        if Int(deviceSelector?.runModal() ?? 0) != kIOBluetoothUISuccess {
            print("User has cancelled the device selection.\n")
            return
        }

        var deviceArray = (deviceSelector?.getResults())!

        let device = deviceArray[0] as? IOBluetoothDevice
        // let device = IOBluetoothDevice(addressString: "38-80-DF-89-27-12")
        
        // # Open RFCOMM Channel
        
        var sppServiceRecord: IOBluetoothSDPServiceRecord? = nil
        sppServiceRecord = device?.getServiceRecord(for: sppServiceUUID)
        if sppServiceRecord == nil {
            print("Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n")
            return
        }
        // To connect we need a device to connect and an RFCOMM channel ID to open on the device:
        var rfcommChannelID: BluetoothRFCOMMChannelID = 0;
        if sppServiceRecord?.getRFCOMMChannelID(&rfcommChannelID) != kIOReturnSuccess {
            print("Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n")
            return
        }
        
        // Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
        if (device?.openRFCOMMChannelAsync(&mRFCOMMChannel, withChannelID: BluetoothRFCOMMChannelID(rfcommChannelID), delegate: self) != kIOReturnSuccess) && (mRFCOMMChannel != nil) {
            // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
            // those details). If the device connection is left open close it and return an error:
            print("Error - open sequence failed.***\n")
            close(device)
            return
        }
        
    }
    
    // # send message
    
    @IBAction func hello(_ sender: AnyObject) {
        let myString = "I am doing ok Android. Thanks for asking";
        
        self.sendMessage(message: myString)
        
    }
    
    func close(_ device: IOBluetoothDevice?) {
    }
    
    func sendMessage(message:String) {
        let data = message.data(using: String.Encoding.utf8)
        let length = data!.count
        let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        
        data?.copyBytes(to: dataPointer,count: length)
        
        print("Sending Message\n")
        mRFCOMMChannel?.writeSync(dataPointer, length: UInt16(length))
    }
    
    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        
        if error != kIOReturnSuccess {
            print("Error - failed to open the RFCOMM channel with error %08lx.\n")
            
            return
        } else {
            print("Connected\n")
        }
        
    }
    
    // # receive message
    
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        
        let message = String(bytesNoCopy: dataPointer, length: Int(dataLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        
        print(message)
    }
}
