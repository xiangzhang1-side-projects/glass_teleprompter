# Android Dev Textbook
[Author][1]

## Build a simple user interface

Layout (Button, buttonText)

android:onclick 

## Start another activity

New Activity
Invoke New Activity by Intent(thisView, newActivity.class); putExtra; startActivity
Receive Invocation by getIntent

Get and set content on page

# [Gradle Textbook][2]
`build.gradle`
	Dependencies {
		# Android plugin for Gradle version as dependency
		classpath 'com.android.tools.build:gradle:3.3.0'
	}
	
	# typical
	allprojects {
	   repositories {
	       google()
	       jcenter()
	   }
	}


[1]:	https://developer.android.com/training/basics/firstapp/
[2]:	https://developer.android.com/studio/build/