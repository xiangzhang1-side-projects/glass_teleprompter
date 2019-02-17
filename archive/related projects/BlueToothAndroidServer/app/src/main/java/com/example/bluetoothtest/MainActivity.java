package com.example.bluetoothtest;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {
    private BluetoothAdapter bluetoothAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // enable bluetooth
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, 1);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        try {

            // create socket
            UUID myUUID = UUID.fromString("e11c6340-2ffd-11e9-b210-d663bd873d93");

            BluetoothServerSocket mmServerSocket = bluetoothAdapter.listenUsingRfcommWithServiceRecord("BluetoothAndroidServer", myUUID);

            toast("socket created");

            // connect

            BluetoothSocket mmSocket = mmServerSocket.accept();

            //write
            OutputStream mmOutStream = mmSocket.getOutputStream();
            mmOutStream.write("msg1".getBytes());

            toast("wrote");

            //write
            mmOutStream.write("msg2".getBytes());

            toast("wrote");

        } catch (Exception IOException) {
            toast("IOException");
        }
    }


    private void toast(String text) {
        // Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
        System.out.println("=============================" + text);
    }
}
