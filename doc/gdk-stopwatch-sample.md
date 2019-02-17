# gdk-stopwatch-sample

# build

	Error: Could not determine the class-path for interface com.android.builder.model.AndroidProject.
[Source][1]Deprecated `android-plugin-gradle` are used. Use latest installed.
[Solution]()Use “official” 2.3.0. Change `build.gradle`

	Error: Could not find method runProguard()
[Source][3]When up-ing from older `gradle`, Replace runProguard with minifyEnabled, Replace zipAlign with zipAlignEnabled

	The SDK Build Tools revision (20.0.0) is too low for project ':app'. Minimum required is 25.0.0
[Source][4]`android-plugin-gradle` 2.3.0 should work with SDK\>=25. Use \<2.2.3.

	Android Gradle plugin and Gradle are not compatible
[AutoSolution](): downgrade `gradle` to 3.5 in `File->Project Structure->Project`

# understand

Too complicated.

# run

`adb shell pm list packages`: not already installed.

`Error: Default Activity not found`: intended. `Run > Edit Configuration > Launch Nothing`

`adb shell pm list packages | grep stopwatch**`: installed.

`adb uninstall com.google.android.glass.sample.stopwatch `: uninstalled.

[1]:	https://stackoverflow.com/questions/42777321/could-not-determine-the-class-path-for-interface-com-android-builder-model-andro
[3]:	http://tools.android.com/tech-docs/new-build-system/migrating-to-1-0-0
[4]:	https://stackoverflow.com/questions/41890659/errorthe-sdk-build-tools-revision-23-0-3-is-too-low-for-project-app-minim
