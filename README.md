# RestKit for Watson Developer Cloud Swift SDK

![](https://img.shields.io/badge/platform-iOS,%20Linux-blue.svg?style=flat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)



## Overview

`RestKit` is a dependency used in the [IBM Watson Swift SDK](https://github.com/watson-developer-cloud/swift-sdk).
It provides the networking layer used by the Swift SDK to communicate between your iOS app and Watson services.
For more information on IBM Watson services, visit the [IBM Watson homepage](https://www.ibm.com/watson/).



## Requirements

- iOS 8.0+
- Xcode 9.0+
- Swift 3.2+ or Swift 4.0+



## Installation

### Dependency Management

We recommend using [Carthage](https://github.com/Carthage/Carthage) to manage dependencies and build RestKit for your application.

You can install Carthage with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

Then, navigate to the root directory of your project (where your .xcodeproj file is located) and create an empty `Cartfile` there:

```bash
$ touch Cartfile
```

To use the RestKit in your application, specify it in your `Cartfile`:

```
github "watson-developer-cloud/restkit"
```

In a production app, you may also want to specify a [version requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

Then run the following command to build the dependencies and frameworks:

```bash
$ carthage update --platform iOS
```

Finally, drag-and-drop the built `RestKit.framework` into your Xcode project and import it in the source files that require it.

### Swift Package Manager

Add the following to your `Package.swift` file to identify RestKit as a dependency. The package manager will clone RestKit when you build your project with `swift build`.

```swift
dependencies: [
    .package(url: "https://github.com/watson-developer-cloud/restkit", from: "1.0.0")
]
```



## Contributing

We would love any and all help! If you would like to contribute, please read our [CONTRIBUTING](https://github.com/watson-developer-cloud/restkit/blob/master/.github/CONTRIBUTING.md) documentation with information on getting started.



## License

This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](https://github.com/watson-developer-cloud/restkit/blob/master/LICENSE).

This SDK is intended for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools.
