# pybluez install log

pip install pybluez
```js
Command "/Library/Frameworks/Python.framework/Versions/2.7/Resources/Python.app/Contents/MacOS/Python -u -c "import setuptools, tokenize;__file__='/private/var/folders/8k/92ykp2bd7599wk_q7mpzcs9r0000gn/T/pip-build-vX_xT2/pybluez/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /var/folders/8k/92ykp2bd7599wk_q7mpzcs9r0000gn/T/pip-_W0YBr-record/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /private/var/folders/8k/92ykp2bd7599wk_q7mpzcs9r0000gn/T/pip-build-vX_xT2/pybluez/
```

[official link][1]  python setup.py install: 
```js
subprocess.CalledProcessError: Command '['xcodebuild', 'install', '-project', 'macos/LightAquaBlue/LightAquaBlue.xcodeproj', '-scheme', 'LightAquaBlue', 'DSTROOT=/Users/xzhang1/src/pybluez/macos', 'INSTALL_PATH=/', 'DEPLOYMENT_LOCATION=YES']' returned non-zero exit status 65
```

commented scheme argument in setup.py. same [source][2]

Tracing
```js
xcodebuild install -project macos/LightAquaBlue/LightAquaBlue.xcodeproj DSTROOT=/Users/xzhang1/src/pybluez/macos INSTALL_PATH=/ DEPLOYMENT_LOCATION=YES
```
Error
```js
error: could not decode input file using specified encoding: Unicode (UTF-16)
```

XCodeBuild; follow re-encode instructions

python setup.py install
```js
Success
```
Import
```js
objc.BadPrototypeError: Objective-C expects 1 arguments, Python argument has 2 arguments for <unbound selector sleep of BBCocoaSleeper at 0x10a114030>
```


Tracing

::Using:: https://github.com/rgov/pybluez.git#egg=pybluez (https://github.com/rgov/pybluez.git)

python setup.py install
```
subprocess.CalledProcessError: Command '['xcodebuild', 'install', '-project', 'osx/LightAquaBlue/LightAquaBlue.xcodeproj', '-scheme', 'LightAquaBlue', 'DSTROOT=/Users/xzhang1/src/pybluez/osx', 'INSTALL_PATH=/', 'DEPLOYMENT_LOCATION=YES']' returned non-zero exit status 65
```

Tracing
```
xcodebuild install -project osx/LightAquaBlue/LightAquaBlue.xcodeproj -scheme LightAquaBlue DSTROOT=/Users/xzhang1/src/pybluez/osx INSTALL_PATH=/ DEPLOYMENT_LOCATION=YES 
```
Error
```
error: could not decode input file using specified encoding: Unicode (UTF-16), and the file contents appear to be encoded in Unicode (UTF-8)
```

Sametrick: Open Xcode, build, follow re-encode instructions

python setup.py install
```
Success
```

```
import bluetooth
```
Warning
```
/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/objc/_bridgesupport.py:13: UserWarning: Module lightblue was already imported from /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/lightblue/__init__.pyc, but /Users/xzhang1/src/pybluez is being added to sys.path
```
Error
```
objc.BadPrototypeError: Objective-C expects 1 arguments, Python argument has 2 arguments for <unbound selector sleep of BBCocoaSleeper at 0x10a019030>
```

TraceWarning
```
trash /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/lightblue/
```

```js
import bluetooth
```
Warning
```
/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/objc/_bridgesupport.py:13: UserWarning: Module lightblue was already imported from /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/PyBluez-0.22-py2.7.egg/lightblue/__init__.pyc, but /Users/xzhang1/src/pybluez is being added to sys.path
```
But succeeded. Decided not to trace warning.

`socket.bind` failed:
```
  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/PyBluez-0.22-py2.7.egg/lightblue/_bluetoothsockets.py", line 62, in _getavailableport
    result, channelID, servicerecordhandle = BBServiceAdvertiser.addRFCOMMServiceDictionary_withName_UUID_channelID_serviceRecordHandle_(BBServiceAdvertiser.serialPortProfileDictionary(), "DummyService", None)
TypeError: Need 5 arguments, got 3
```
TypeError was raised by `<bjective-c BBServiceAdvertiser. addRFCOMMServiceDictionary_withName_UUID_channelID_serviceRecordHandle_`
Original error was masked due to a catch-all.
Removed try-except clause in `_bluetoothsockets.py: 62`.
`BBServiceAdvertiser.addRFCOMMServiceDictionary_withName_UUID_channelID_serviceRecordHandle_` Somehow returns an integer, not an iterable, breaking the lib.

Case closed.

[1]:	https://github.com/karulis/pybluez
[2]:	https://stackoverflow.com/questions/34319425/working-with-bluetooth-le-devices-on-osx