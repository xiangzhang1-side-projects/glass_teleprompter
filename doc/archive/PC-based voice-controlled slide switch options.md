# PC-based voice-controlled slide switch options

PC voice recognition should be easy. 

But: 
- How do I make sure Glass is on?
- How do I signal glass to switch slide? 

# Make glass on

## Mirror API

[Source][1] 
The Glass team has decided against allowing developers to use the Mirror API to automatically turn on screens [1][2]

## System-level

[Source][3]
You can create your own simple app that changes the screen timeout value.
```js
//change screen timeout to 60 min
    android.provider.Settings.System.putInt(getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT, 600000);
```

And you also need to specify some permissions:
```js
<uses-permission android:name="android.permission.WRITE_SETTINGS"/>
```

Using this I was able to keep my screen awake no matter if I was into an application or visualizing the live cards. At least for my 19.1 version of Glass

## Layout attribute using GDK

[Source][4] Ans1

## Power manager in GDK

Power manager

# How do I signal a glass?

## Mirror API

- Timeline. Insert cards, add images and videos, bundle multiple cards, and access Timeline items.
- Menu Items. Make your cards interactive, using either built-in functionality or your own custom functionality.
- Subscriptions. Allows the developer to get notifications when a user performs specific actions such as sharing or updating location, or even voice detection. The developer can then respond to these user actions.

This requires that Mirror-pushed cards are topmost.
1. They are not.
2. Timeline-based syncs are TOO SLOW (\>30s) for real-time presentation.

## GDK receive

GDK itself doesn’t accept requests.
GDK can make very frequent requests.

You can [use firebase][5], part of Android, to get requests. It is a GlassApp.

You can send bluetooth input to Google Glass.

[1]:	https://code.google.com/archive/p/google-glass-api/issues/74
[2]:	https://stackoverflow.com/questions/17455113/how-to-raise-the-notification-level-of-timeline-updates
[3]:	https://stackoverflow.com/questions/21403837/gdk-keep-screen-from-dimming-on-a-live-card
[4]:	https://stackoverflow.com/questions/18502143/gdk-apk-for-google-glass-keep-screen-from-dimming
[5]:	https://github.com/mimming/firebase-fruit-detector/blob/master/google-glass/app/src/main/java/com/firebase/sample/fruitdetector/DetectFruitActivity.java