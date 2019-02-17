# GGTeleprompter

Usage
1. Convert demo.key to XML: `python2 keynote2xml.py`
2. Copy-paste XML content to HelloGlass/res/keynote.xml, overwrite
3. Run -\> Configuration: Launch Nothing to install
4. XCode open BTServerListener -\> Run, see Service Name
5. Run app on Glass (Developer mode)
Note:
- Not necessary to run only once after install (robust), but preferable
- If Bluetooth connect dialog shows (-48589890), use related projects -\> working RFCOMM swift wl GUI to pair
- For current demo.key, skip 1-2.
- Overlapping rfcommChannelData on mac (Hidden slides, scrolling too fast) crashes the connection.

Design
```java
HotwordRecognizer, SWIPE
-> _
-> mCards(text hotword time), BluetoothClientSender (->BluetoothServerListener), HotwordRecognizer
```
However, the natural scroll-y mCards.next cannot be obtained (esp. with scroll speed etc) programatically.
Instead, 
1. a gesture can be simulated.
2. no-transition setSelection, notifyDataSetChanged 

Implementation: simulate gesture, listen gesture. good for relative position.
```java
HotwordRecognizer -> SWIPE

GestureListener
super.ONSWIPE (ie mCards), BluetoothClientSender, HotwordRecognizer
```

Implementation: simulate gesture, listen selected. I/O separated elegantly.
```java
HotwordRecognizer -> SWIPE

onSelectedListener
BluetoothClientSender.sync(page), HotwordRecognizer
```
Note: getView() updates timestamp

Implementation: no-transition
```java
HotwordRecognizer, SWIPE
-> _
-> mCards.setSelection, BluetoothClientSender, HotwordRecognizer
```

Techniques used:
Bluetooth
CMUSphinx VoiceRecognition
Google Glass GDK
Android / Java
macOS / Swift