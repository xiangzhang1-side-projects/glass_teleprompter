package com.example.bluetoothtest;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Set;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {

    private BluetoothClientSender mBluetoothClientSender;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, 1);

        mBluetoothClientSender = new BluetoothClientSender();
        mBluetoothClientSender.next();
    }
}

/*
BluetoothClientSender
- connects to MACADDR 18:65:90:CF:A2:1C with UUID e11c6340-2ffd-11e9-b210-d663bd873d93
- sends text
Pre-requisite:
- proper bluetooth permissions (AndroidManifest.xml, possibly explicitly request permission in onCreate)
Usage:
- m = BluetoothClientSender()
- m.send(text)           // sends text to mac
- m.next() / m.prev()    // sends next/prev
*/
class BluetoothClientSender {

    private BluetoothAdapter bluetoothAdapter;
    private OutputStream mmOutStream;

    public BluetoothClientSender() {
        // enable bluetooth
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        try {
            // create socket
            BluetoothDevice device = bluetoothAdapter.getRemoteDevice("18:65:90:CF:A2:1C");
            UUID uuid = UUID.fromString("e11c6340-2ffd-11e9-b210-d663bd873d93");
            BluetoothSocket socket = device.createInsecureRfcommSocketToServiceRecord(uuid);

            // connect
            socket.connect();
            mmOutStream = socket.getOutputStream();
        } catch (Exception e) {
            toast("init exception");
        }
    }

    public void send(String text) {
        // send
        try {
            mmOutStream.write(text.getBytes());
        } catch (Exception e) {
            toast("send exception");
        }
    }

    public void next() { send("next"); }

    public void prev() { send("prev"); }

    private void toast(String text) {
        System.out.println("==================" + text);
    }

}
