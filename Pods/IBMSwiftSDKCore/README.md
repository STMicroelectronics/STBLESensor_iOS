# IBM Swift SDK Core

![](https://img.shields.io/badge/platform-iOS,%20Linux-blue.svg?style=flat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/IBMSwiftSDKCore.svg?style=flat)](http://cocoadocs.org/docsets/IBMSwiftSDKCore)
[![CLA assistant](https://cla-assistant.io/readme/badge/watson-developer-cloud/IBMSwiftSDKCore)](https://cla-assistant.io/IBM/swift-sdk-core)

## Overview

`IBMSwiftSDKCore` is a dependency used in the [IBM Watson Swift SDK](https://github.com/watson-developer-cloud/swift-sdk).
It provides the networking layer used by the Swift SDK to communicate between your Swift app and IBM Services.
For more information on IBM Watson services, visit the [IBM Watson homepage](https://www.ibm.com/watson/). Currently, it is only used by the IBM Watson Swift SDK, but it will be used by other IBM service SDKs in the future.


## Requirements

- Xcode 9.3+
- Swift 4.2+
- iOS 10.0+

## Installation

IBMSwiftSDKCore can be installed with [Cocoapods](http://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage), or [Swift Package Manager](https://swift.org/package-manager/).

### Cocoapods

You can install Cocoapods with [RubyGems](https://rubygems.org/):

```bash
$ sudo gem install cocoapods
```

If your project does not yet have a Podfile, use the `pod init` command in the root directory of your project. To install IBMSwiftSDKCore using Cocoapods, add the following to your Podfile (substituting `MyApp` with the name of your app). 

```ruby
use_frameworks!

target 'MyApp' do
    pod 'IBMSwiftSDKCore', '~> 1.0.0'
end
```

Then run the `pod install` command, and open the generated `.xcworkspace` file. To update to a newer release of IBMSwiftSDKCore, use `pod update IBMSwiftSDKCore`.

For more information on using Cocoapods, refer to the [Cocoapods Guides](https://guides.cocoapods.org/using/index.html).

### Carthage

You can install Carthage with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

If your project does not have a Cartfile yet, use the `touch Cartfile` command in the root directory of your project. To install IBMSwiftSDKCore using Carthage, add the following to your Cartfile. 

```
github "IBM/swift-sdk-core" ~> 1.0.0
```

Then run the following command to build the dependencies and frameworks:

```bash
$ carthage update --platform iOS
```

Follow the remaining Carthage installation instructions [here](https://github.com/Carthage/Carthage#getting-started). Make sure to drag-and-drop the built `IBMSwiftSDKCore.framework` into your Xcode project and import it in the source files that require it.

### Swift Package Manager

Add the following to your `Package.swift` file to identify IBMSwiftSDKCore as a dependency. The package manager will clone IBMSwiftSDKCore when you build your project with `swift build`.

```swift
dependencies: [
    .package(url: "https://github.com/IBM/swift-sdk-core", from: "1.0.0")
]
```

## Contributing

We would love any and all help! If you would like to contribute, please read our [CONTRIBUTING](https://github.com/watson-developer-cloud/IBMSwiftSDKCore/blob/master/.github/CONTRIBUTING.md) documentation with information on getting started.

## License

This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](https://github.com/watson-developer-cloud/IBMSwiftSDKCore/blob/master/LICENSE).

This SDK is intended for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools.