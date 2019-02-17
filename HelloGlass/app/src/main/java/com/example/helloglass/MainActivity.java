package com.example.helloglass;

import com.google.android.glass.widget.CardBuilder;
import com.google.android.glass.widget.CardScrollView;
import com.google.android.glass.widget.CardScrollAdapter;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.ArrayList;
import java.util.UUID;

import edu.cmu.pocketsphinx.Assets;
import edu.cmu.pocketsphinx.Hypothesis;
import edu.cmu.pocketsphinx.RecognitionListener;
import edu.cmu.pocketsphinx.SpeechRecognizer;
import edu.cmu.pocketsphinx.SpeechRecognizerSetup;

public class MainActivity extends Activity {

    private HotwordRecognizer mHotwordRecognizer;

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);   // keep screen on

        HotwordRecognizer mHotwordRecognizer = new HotwordRecognizer(this);
        BluetoothClientSender mBluetoothClientSender = new BluetoothClientSender();
        Cards mCards = new Cards(this, mHotwordRecognizer, mBluetoothClientSender);
    }

    @Override
    protected void onStop() {
        super.onStop();

        mHotwordRecognizer.onStop();
    }
}

/*
mCards
 create a Card Scroller from XML file, setView
Usage:
 new mCards()    // from MainActivity
Customization:
 onSelectedListener(): mCards(time), BluetoothClientSender.send(page), HotwordRecognizer.setHotword()
*/
class Cards {

    private class UdfCardScrollAdapter extends CardScrollAdapter {
        @Override
        public int getPosition(Object item) {
            return mCardBuilders.indexOf(item);
        }
        @Override
        public int getCount() {
            return mCardBuilders.size();
        }
        @Override
        public Object getItem(int position) {
            return mCardBuilders.get(position);
        }
        @Override
        public int getViewTypeCount() {
            return CardBuilder.getViewTypeCount();
        }
        @Override
        public int getItemViewType(int position){
            return mCardBuilders.get(position).getItemViewType();
        }
        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            return mCardBuilders.get(position).getView(convertView, parent);
        }
    }

    private String[] hotwords;
    private String[] texts;

    private List<CardBuilder> mCardBuilders;
    private CardScrollView mCardScrollView;
    private UdfCardScrollAdapter mAdapter;

    public Cards(Context context, final HotwordRecognizer mHotwordRecognizer, final BluetoothClientSender mBluetoothClientSender) {
        int nSlides = context.getResources().getInteger(R.integer.nslides);
        texts = context.getResources().getStringArray(R.array.texts);
        hotwords = context.getResources().getStringArray(R.array.hotwords);

        mCardBuilders = new ArrayList<CardBuilder>();
        for (int _ = 0; _ < nSlides; _++) {
            String text = texts[_];
            String footnote = hotwords[_];
            String timestamp = "TBD";
            mCardBuilders.add(new CardBuilder(context, CardBuilder.Layout.TEXT)
                    .setText(text)
                    .setFootnote(footnote)
                    .setTimestamp(timestamp));
        }

        mAdapter = new UdfCardScrollAdapter();

        mCardScrollView = new CardScrollView(context);
        mCardScrollView.setAdapter(mAdapter);
        mCardScrollView.activate();

        // Customization: onSelectedListener()
        mCardScrollView.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // local new class
            private final long t0 = System.currentTimeMillis();
            private boolean onItemSelectedRenderOnly = false;

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) { // position from 0
                System.out.println("==========onItemSelected" + Integer.toString(position));

                // read this after reading mCards(refresh time), BluetoothClientSender.sync(page), HotwordRecognizer
                // mCards(refresh time), as a side effect, invokes this func. to break loop, alternate do everything / do nothing
                if (onItemSelectedRenderOnly)
                    onItemSelectedRenderOnly = false;
                else {
                    onItemSelectedRenderOnly = true;

                    // mCards(time)
                    long t = System.currentTimeMillis();
                    long tDelta = t - t0;
                    long elapsedSeconds = tDelta / 1000;
                    long minute = elapsedSeconds / 60;
                    long second = elapsedSeconds % 60;

                    mCardBuilders.get(position).setTimestamp(String.format("%s:%s", minute, second));
                    mAdapter.notifyDataSetChanged();

                    // BluetoothClientSender.send(page)
                    mBluetoothClientSender.send(Integer.toString(position + 1)); // slide index from 1

                    // HotwordRecognizer
                    mHotwordRecognizer.setHotword(hotwords[position]);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        ((Activity) context).setContentView(mCardScrollView);
        mAdapter.notifyDataSetChanged();
    }

}


/*
Usage:
 Simulate `adb shell input keyevent <keycode here>` by `IssueKey.issueKey(22)`
Google Glass keyCode list:
 4: Swipe Down
 21: Swipe Left
 22: Swipe Right
 23: Tap
 24: Volume Up
 25: Volume Down
 26: Lock/Unlock Screen
 27: Camera Button
 */
class IssueKey {
    public static void issueKey(int keyCode)        // static method, no need for instantiation
    {
        try {
            java.lang.Process p = java.lang.Runtime.getRuntime().exec("input keyevent " + Integer.toString(keyCode) + "\n");
        } catch (Exception e) {
            System.out.println("issueKey exception");
        }
    }
}

/*
Prerequisite:
 proper permission in Android.manifest
 add onStop to MainActivity.onStop (so that swipe-down re-start works)
Usage:
 h = HotwordRecognizer(this);         // instantiate inside MainActivity
 h.setHotword("oh mighty computer")   // start listening
 on detection, onPartialResults() is run
Customization:
 onPartialResults(): IssueKey(SWIPE_RIGHT)
*/
class HotwordRecognizer implements RecognitionListener {

    private SpeechRecognizer recognizer;
    private String currentHotword;

    public HotwordRecognizer(Context context) {
        // initialize before use
        try {
            Assets assets = new Assets(context);
            File assetsDir = assets.syncAssets();

            recognizer = SpeechRecognizerSetup.defaultSetup()
                    .setAcousticModel(new File(assetsDir, "en-us-ptm"))
                    .setDictionary(new File(assetsDir, "cmudict-en-us.dict"))
                    .getRecognizer();
            recognizer.addListener(this);
        } catch (IOException e){
            toast(e.getMessage());
        }
    }

    // Partial results are what you'll want to listen to.
    public void setHotword(String hotword) {
        currentHotword = hotword;
        if (recognizer != null)
            recognizer.stop();

        recognizer.addKeyphraseSearch(hotword, hotword);
        recognizer.startListening(hotword);
    }

    @Override
    public void onPartialResult(Hypothesis hypothesis) {
        if (hypothesis == null)
            return;
        if (recognizer != null)
            recognizer.stop();

        String text = hypothesis.getHypstr();
        if (text.equals(currentHotword)) {
            IssueKey.issueKey(22);
            toast("Issue your goddamn key");
        }
    }

    // unskippable boilerplate
    @Override
    public void onResult(Hypothesis hypothesis) {
    }

    @Override
    public void onBeginningOfSpeech() {
    }

    @Override
    public void onEndOfSpeech() {
    }

    @Override
    public void onError(Exception error) {
    }

    @Override
    public void onTimeout() {
    }

    public void onStop() {
        if (recognizer != null) {
            recognizer.cancel();
            recognizer.shutdown();
        }
    }

    private void toast(String text) {
        System.out.println(text);
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

    private BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();;
    private BluetoothDevice device = bluetoothAdapter.getRemoteDevice("18:65:90:CF:A2:1C");
    private UUID uuid = UUID.fromString("e11c6340-2ffd-11e9-b210-d663bd873d93");
    private OutputStream mmOutStream;

    public BluetoothClientSender() {
        connect();
    }

    private void connect() {
        try {
            // create socket
            BluetoothSocket socket = device.createRfcommSocketToServiceRecord(uuid);

            // connect
            socket.connect();
            mmOutStream = socket.getOutputStream();
        } catch (Exception e) {
            toast("connect exception");
        }
    }

    public void send(String text) {
        // send
        for(int count = 0; count < 3; count++) {
            try {
                toast("sending " + text);
                mmOutStream.write(text.getBytes());
                count = 3;
            } catch (Exception e) {
                toast("send exception" + e.getMessage());
                connect();
            }
        }
    }

    private void toast(String text) {
        System.out.println("==================" + text);
    }

}
