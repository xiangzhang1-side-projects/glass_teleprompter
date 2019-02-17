//  Converted to Swift 4 by Swiftify v4.2.34952 - https://objectivec2swift.com/
//
//  ViewController.swift
//  rfcommServer
//
//  Created by Romain Quidet on 08/12/2015.
//  Copyright © 2015 xdappfactory. All rights reserved.
//

import Cocoa
import IOBluetooth

class ViewController: NSViewController, IOBluetoothRFCOMMChannelDelegate {
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var sendTextField: NSTextField!
    @IBOutlet var receiveTextView: NSTextView!

    @IBAction func sendButtonTapped(_ sender: Any) {
        DLog("")
        if sendTextField.stringValue.count > 0 {
            let bytes = sendTextField.stringValue.utf8CString
            currentRFCOMMChannel?.writeAsync(&bytes, length: UInt16(sendTextField.stringValue.count), refcon: nil)
        }
    }

    private var rfcommChannelID: BluetoothRFCOMMChannelID = 0
    private var sdpServiceRecordHandle: BluetoothSDPServiceRecordHandle = 0
    private var incomingRFCOMMChannelNotification: IOBluetoothUserNotification?
    private var currentRFCOMMChannel: IOBluetoothRFCOMMChannel?

// MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DLog("")
        receiveTextView.isEditable = false

        // Turn on Discoverability
        if !IOBluetoothPreferenceGetDiscoverableState() {
            IOBluetoothPreferenceSetDiscoverableState(1)
        }

        // start our RFCOMM server
        let res: Bool = publishService()
        if !res {
            receiveTextView.string = "Error, can't publish RFCOMM server"
        } else {
            receiveTextView.string = "RFCOMM server ready\r\n"
        }
    }

    override var representedObject: Any? {
        get {
            return super.representedObject
        }
        set(representedObject) {
            super.representedObject = representedObject
    
            // Update the view, if already loaded.
        }
    }

// MARK: - Internals
    func publishService() -> Bool {
        DLog("Enter")

        // Load SDP config dictionary
        let dictionaryPath = Bundle.main.path(forResource: "SerialPortDictionary", ofType: "plist")
        var sdpEntries = NSDictionary(contentsOfFile: dictionaryPath ?? "")

        // Publish SDP service
        let serviceRecord = IOBluetoothSDPServiceRecord.publishedServiceRecord(with: sdpEntries as [AnyHashable : Any]) as? IOBluetoothSDPServiceRecord

        var res: IOReturn? = serviceRecord?.getRFCOMMChannelID(&rfcommChannelID)
        if res != kIOReturnSuccess {
            DLog("getRFCOMMChannelID failed: %@", NSNumber(value: res!))
            return false
        }
        res = serviceRecord?.getHandle(&sdpServiceRecordHandle)
        if res != kIOReturnSuccess {
            DLog("getServiceRecordHandle failed: %@", NSNumber(value: res!))
            return false
        }

        DLog("Service Name is %@", serviceRecord?.getServiceName())

        // Register a notification so we get notified when an incoming RFCOMM channel is opened
        // to the channel assigned to our chat service.
        incomingRFCOMMChannelNotification = IOBluetoothRFCOMMChannel.register(forChannelOpenNotifications: self, selector: #selector(ViewController.newRFCOMMChannelOpened(_:channel:)))
        return true
    }

// MARK: - UI interface

// MARK: - RFCOMM open notification
    @objc func newRFCOMMChannelOpened(_ inNotification: IOBluetoothUserNotification?, channel newChannel: IOBluetoothRFCOMMChannel?) {
        DLog("")
        if inNotification?.isEqual(incomingRFCOMMChannelNotification) ?? false {
            DLog("Good, our RFCOMM channel is in use")
            newChannel?.delegate() = self
            currentRFCOMMChannel = newChannel
        } else {
            DLog("Mhh doesn't seems to be our channel id")
        }
    }

// MARK: - RFCOMM Channel delegate
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        DLog("got %@ bytes", NSNumber(value: dataLength))
    }

    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        DLog("open %@", error == kIOReturnSuccess ? "OK" : "Error")
    }

    func rfcommChannelClosed(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        DLog("")
    }

    func rfcommChannelControlSignalsChanged(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        DLog("")
    }

    func rfcommChannelFlowControlChanged(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        DLog("")
    }

    func rfcommChannelWriteComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, refcon: UnsafeMutableRawPointer!, status error: IOReturn) {
        DLog("write %@", error == kIOReturnSuccess ? "OK" : "Error")
    }

    func rfcommChannelQueueSpaceAvailable(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        DLog("")
    }
}