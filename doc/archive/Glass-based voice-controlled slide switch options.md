# Glass-based voice-controlled slide switch options

# Voice recognition options

## GDK RecognizerIntent | Foreground ; Background

[Textbook]()
- ok glass -\> context menu
- New Activity
```js
Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
startActivityForResult(intent, SPEECH_REQUEST);
```

[stackexchange][2]

## ？

[random github][3]: `com.google.glass.input.VoiceInputHelper` can be used. No documentation!

# android.voicesearch (PROBABLY SAME THING)

[stackexchange][4]: `com.google.android.voicesearch` apk is needed. for example, ICS VoiceSearch.apk 2.1.4 ver. change the miniSDK to 15. __OR NOT NEEDED__
then
```js
startActivityForResult(new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH));
```

[GLASS! GlassPrompter github][5]: use VoiceSearch.apk, use SpeechRecognizer (Android)

# Hotword options

`PocketSphinx` works for magic words OFFLINE. [Source][6][Source][7]Probably doesn’t work on the weakling Google Glass.

`Snowboy`

`AlwaysOnHotwordDetector` was added SDK21. Also unrequestable permission needed. [Source][8]

[2]:	https://stackoverflow.com/questions/23614814/run-speech-recognizer-as-background-service-in-google-glass
[3]:	https://github.com/RIVeR-Lab/google_glass_driver/blob/master/android/RobotManager/src/com/riverlab/robotmanager/voice_recognition/VoiceRecognitionThread.java
[4]:	https://stackoverflow.com/questions/17414251/using-android-speech-recognition-apis-from-google-glass
[5]:	https://github.com/OkGoDoIt/GlassPrompter
[6]:	https://sourceforge.net/p/cmusphinx/discussion/help/thread/94ef50c1/
[7]:	https://stackoverflow.com/questions/27190486/how-to-add-phonemes-recognition-with-pocketsphinx-on-android
[8]:	https://stackoverflow.com/questions/26834163/example-of-alwaysonhotworddetector-in-android