# PocketSphinx Textbook

[Author][1]

# Include AAR
Go to the Pocketsphinx Android demo Github page, open ‘aars‘ directory and download ‘pocketsphinx-android-5prealpha-release.aar‘.
File \> New \> New module \> Import .JAR/.AAR Package

Open settings.gradle in your project and (if its not there already) add pocketsphinx to your include line:
```js
include ':app', ':pocketsphinx-android-5prealpha-release'
```

Open app/build.gradle and add this line to dependencies:
```js
compile project(':pocketsphinx-android-5prealpha-release')
```

Add permission to project `Android.manifest`
```js
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```
On Android\>4.4, in `onCreate()`
```js
ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 1);
```

Go to Pocketsphinx Android demo page on github and download file assets.xml from ‘models‘ directory, and put it in the app/ folder of your project.

Go back to app/build.gradle in your project and add these lines to its absolute end:
```js
ant.importBuild 'assets.xml'
preBuild.dependsOn(list, checksum)
clean.dependsOn(clean_assets)
```

On the Pocketsphinx Android demo page, navigate to models/src/main/assets, download the ‘sync’ folder and copy it to your ‘assets‘ folder (which you right click New \> Folder \> Asset Folder) in your project. 

# Import

```js
import android.Manifest;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.support.v4.app.ActivityCompat;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;

import edu.cmu.pocketsphinx.Assets;
import edu.cmu.pocketsphinx.Hypothesis;
import edu.cmu.pocketsphinx.RecognitionListener;
import edu.cmu.pocketsphinx.SpeechRecognizer;
import edu.cmu.pocketsphinx.SpeechRecognizerSetup;
```


# Code

Framework
```js
public class MainActivity extends Activity implements RecognitionListener {

	private SpeechRecognizer recognizer;

	@Override
	public void onPartialResult(Hypothesis hypothesis) {
		// returns recognized text, frequently
		hypothesis.getHypstr();
	}

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

    @Override
    public void onStop() {
        super.onStop();
        if (recognizer != null) {
            recognizer.cancel();
            recognizer.shutdown();
        }
    }
}
```

initialize before use
```js
try {
	Assets assets = new Assets(MainActivity.this);
	File assetsDir = assets.syncAssets();

	recognizer = SpeechRecognizerSetup.defaultSetup()
			.setAcousticModel(new File(assetsDir, "en-us-ptm"))
			.setDictionary(new File(assetsDir, "cmudict-en-us.dict"))
			//.setRawLogDir(assetsDir)	// don't save raw audio files
			.getRecognizer();
	recognizer.addListener(this);

} catch (IOException e){
	System.out.println(e.getMessage());
}
```

begin/restart listening for hotword `text`
```js
private void listenFor(String text) {
	if (recognizer != null) 
		recognizer.stop();

	recognizer.addKeyphraseSearch(text, text);
	recognizer.startListening(text);
}
```


[1]:	https://www.guidearea.com/pocketsphinx-continuous-speech-recognition-android-tutorial/