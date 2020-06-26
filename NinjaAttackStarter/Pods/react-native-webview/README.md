# Mopinion Mobile SDK iOS

The Mopinion Mobile SDK can be used to collect feedback from iOS apps based on events.
To use Mopinion mobile feedback forms in your app you can include the SDK as a Framework in your Xcode project.

There is also a Mopinion Mobile SDK for Android available [here](https://github.com/mopinion/mopinion-sdk-android).

You can see how your mobile forms will look like in your app by downloading our [Mopinion Forms](https://itunes.apple.com/nl/app/mopinion-forms/id1376756796?l=en&mt=8) preview app from the Apple iOS App Store.

## Install

For Xcode 11, the Mopinion Mobile SDK Framework can be installed by using the popular dependency manager [Cocoapods](https://cocoapods.org).
The SDK is partly built with [React Native](https://facebook.github.io/react-native/), it needs some Frameworks to function.

### Install with Cocoapods

Install using Cocoapods. This method works for Xcode 11.4. For earlier versions of Xcode, follow the procedure under "Install with Cocoapods and React Native" using an earlier version of our SDK.

`$ sudo gem install cocoapods`

make a `Podfile` in root of your project:

```ruby
platform :ios, '9.0'
use_frameworks!
target '<YOUR TARGET>' do
	pod 'MopinionSDK',  '~> 0.4.4'
	pod 'React', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
	pod 'react-native-webview', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
	pod 'yoga', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
	pod 'DoubleConversion', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
	pod 'GLog', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
	pod 'Folly', :git => 'git@github.com:mopinion/mopinion-sdk-ios.git'
end
```

Install the needed pods:

`$ pod install`

After this you should use the newly made `*.xcworkspace` file in Xcode.

### Install with Cocoapods and React Native (Node.js)

Alternatively, install the React Native frameworks via Node.js. 

[Install Node.js/npm](https://www.npmjs.com/get-npm)

make a `package.json` file in the root of your project:

```javascript
{
  "name": "MopinionSDK",
  "version": "0.1.0",
  "dependencies": {
    "react": "16.8.6",
    "react-native": "^0.59.10",
    "react-native-webview": "^9.2.2"
  }
}
```

`$ npm install`

Note: if you decide to use react-native version 0.59.10 then you'll manually need to remove UIWebView from its source code if you want your App to be accepted by the Appstore.

Now you can install everything with Cocoapods with a `Podfile` like this (assuming the `node_modules` folder is in the same location as your `Podfile`) 
for Xcode 11.4 :

```ruby
platform :ios, '9.0'
use_frameworks!
target '<YOUR TARGET>' do
	pod 'MopinionSDK',  '>= 0.4.4'
	pod 'React', :path => './node_modules/react-native', :subspecs => [
	  'Core',
	  'CxxBridge',
	  'DevSupport',
	  'RCTImage',
	  'RCTNetwork',
	  'RCTText',
	  'RCTWebSocket',
	  'RCTAnimation'
	]
	pod 'yoga', :path => './node_modules/react-native/ReactCommon/yoga'
	pod 'react-native-webview', :path => './node_modules/react-native-webview/react-native-webview.podspec'
	pod 'DoubleConversion', :podspec => './node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
	pod 'GLog', :podspec => './node_modules/react-native/third-party-podspecs/GLog.podspec'
	pod 'Folly', :podspec => './node_modules/react-native/third-party-podspecs/Folly.podspec'
end
```

Next perform a
 
`$ pod install`

After this you should use the newly created `*.xcworkspace` file in Xcode.

### font

The SDK includes a font that should be added to the fonts list in the `Info.plist` file of your project.

Add this font to your app's `Info.plist` > `Fonts provided by application`:   
- `Frameworks/MopinionSDK.framework/FontAwesome.ttf`

## Implement the SDK

In your app code, for instance the `AppDelegate.swift` file, put:

```swift
import MopinionSDK
...
// debug mode
MopinionSDK.load(<MOPINION DEPLOYMENT KEY>, true)
// live
MopinionSDK.load(<MOPINION DEPLOYMENT KEY>)
```

The `<MOPINION DEPLOYMENT KEY>` should be replaced with your specific deployment key. This key can be found in your Mopinion account at the `Feedback forms` section under `Deployments`.

in a UIViewController, for example `ViewController.swift`, put:

```swift
import MopinionSDK
...
MopinionSDK.event(self, "_button")
```
where `"_button"` is the default passive form event.
You can also make custom events and use them in the Mopinion deployment interface.  
In the Mopinion system you can enable or disable the feedback form when a user of your app executes the event.
The event could be a touch of a button, at the end of a transaction, proactive, etc.

## extra data

From version `0.3.1` it's also possible to send extra data from the app to your form. 
This can be done by adding a key and a value to the `data()` method.
The data should be added before the `event()` method is called if you want to include the data in the form that comes up for that event.

```swift
MopinionSDK.data(_key: String, _value: String)
```

Example:
```swift
import MopinionSDK
...
MopinionSDK.data("first name": "Steve")
MopinionSDK.data("last name": "Jobs")
...
MopinionSDK.event(self, "_button")
```

## clear extra data

From version `0.3.4` it's possible to remove all or a single key-value pair from the extra data previously supplied with the `data(key,value)` method.
To remove a single key-value pair use this method:

```swift
MopinionSDK.removeData(forKey: String)
```
Example:

```swift
MopinionSDK.removeData(forKey: "first name")
```

To remove all supplied extra data use this method without arguments:

```swift
MopinionSDK.removeData()
```
Example:

```swift
MopinionSDK.removeData()
```

## Edit triggers

In the Mopinion system you can define events and triggers that will work with the SDK events you created in your app.
Login to your Mopinion account and go to the form builder to use this functionality.

The custom defined events can be used in combination with rules:

* trigger: `passive` or `proactive`. A passive form always shows when the event is triggered. A proactive form only shows once, you can set the refresh time after which the form should show again.  
* percentage (proactive trigger): % of users that should see the form  
* date: only show the form at at, after or before a specific date or date range  
* time: only show the form at at, after or before a specific time or time range  
* target: show the form only in the specified OS (iOS or Android)
