# List of bluetooth libraries for Mac

# macOS and third-party RFCOMM

`LightBlue` claims to work. Try it!
> Current PyObjC: 5.5.1+. Compatibility: 3.0.1-. 3.1.0 PyObjC no long installs at all.

`bluecove` claims to be a Java RFCOMM API. Pretty old (2008) tho. Try it!
> Eventually did not work.
Works… Almost. Funky as fuck. Never receives the message.

Python3.3 as installed by pip doesn’t support Bluetooth. Recompile it!
> NOPE.
export CPPFLAGS='-I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/pcap'
WHY TF DID I THINK IT WOULD WORK? pcap/bluetooth.h is shitty as fuck. Cannot make.

A Swift tutorial using Central Bluetooth, and a [Web interface][1] using BLE, found nothing. I would assume that "make discoverable" is more RFCOMM-ish.

Only thing I know: Mac supports Classic Bluetooth (e.g. Bose) and LE (headphoneLE.xzhang1, which led to problems). Bluetooth is a pile of shit.

pybluez
> Eventually did not work due to an outdated API.

By the way, RFCOMM is NOT deprecated.

# macOS and third-party BLE

Central Bluetooth (BLE) and IOBluetooth (RFCOMM) exists, but the tutorial are both inhumane.

`node.js/noble` (BLE) uses XPC connection and fails for mojave. `noble-mac` fares no better.

# My MAC addresses

mbp2015: 18:65:90:CF:A2:1C
moto e5: 38-80-df-89-27-12
google glass: f8-8f-ca-25-f2-28

[1]:	https://googlechrome.github.io/samples/web-bluetooth/device-info.html?allDevices=true