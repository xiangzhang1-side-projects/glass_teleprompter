# PocketSphinx Usage

# Include AAR

File \> New \> New module \> Import .JAR/.AAR Package

Once the AAR is imported as module into the project, make sure it is listed as a dependency of a main module in app/build.gradle:
```js
dependencies {
   compile project(':aars')
}
```
 
# Permission
Top-level `Android.manifest`
```js
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```
