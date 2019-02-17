# GDK error msg archive

# No Main Application

That’s intended; Google Glass don’t use them.

Anyways, add those two lines from AndroidManifest.xml to your supposed entry point.

# Android Studio version 

0.8.16 (third-party): java 6 ran into problems

1.5.0 (third-party): internal error. Well fuck

2.3.0 (official archive)
Error:failed to find target Google Inc.:Glass Development Kit Preview:19 : /Users/xzhang1/Library/Android/sdk
---- 
Stackexchange:
Newer versions of Gradle Android plugin don’t work.
open the top level build.gradle, and change to
	classpath 'com.android.tools.build:gradle:2.2.3'
---- 
me: older version (1.1.0) don’t work. 2.2.0 work.
---- 
Error:Failed to find Build Tools revision 20.0.0
---- 
Me: I though it’s unnecessary? Comment out? Nope.
Me: well just download it then
---- 
Error: requires gradle 2.14.1 or newer. Note: newer gradel requires newer plugin. Then requires new build tools version.
Me: fuck. Okay do it.
---- 
Error: still failed to find shit
_ Stackexchange: change module-level compilerSdkVersion to 19._ (Me: YeahMakesSense, manual never says sub-sdk.)
Me: well fuck change everything back


StopWatch sample
Error:Could not determine the class-path for interface com.android.builder.model.AndroidProject.
---- 
Stackexchange: Google doesn't update ADT any more, so when Eclipse export a project to gradle, it use an old gradle plugin version that Android Studio doesn't support. Eg gradle 0.12.+
See what version you’ve installed, change to it.
Me: copy from previous.
NOPE
---- 
Stackexhcnage: 
Build.gradle -\> Plugin 3.0.1 classpath 'com.android.tools.build:gradle:3.0.1'
Gradle-wrapper.properties -\> Gradle gradle-3.3-all.zip
---- 
Error: cannay find 3.0.1
Stackexchange: gradle-4.1-all.zip
nay
----
_ Me: fuck another version, 2.2.0_
----
Error: no run-pro-guard
——
Stackexchange:
!!
There is an update with Android Studio, you need to migrate your Gradle configurations : http://tools.android.com/tech-docs/new-build-system/migrating-to-1-0-0

_ Replace runProguard with minifyEnabled_
Replace zipAlign with zipAlignEnabled

Ah ha ha so everything needs retune fuck me
