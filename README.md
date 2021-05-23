<p align="center">
<img src="https://github.com/DevYeom/ModernRIBs/blob/assets/modernrib_horizontal_image.png" width="60%" height="60%" alt="ModernRIBs"/>
</p>

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/ModernRIBs.svg)](https://cocoapods.org/pods/ModernRIBs)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

ModernRIBs is recreated by removing additional dependencies such as RxSwift from [Uber's RIBs](https://github.com/uber/RIBs). Only Combine was used. All features provided by RIBs can be used identically, and it will be continuously updated according to the RIBs updated version. Therefore, the version will be matched with the RIBs. It is expected to be useful in projects that do not use RxSwift or with a minimum supported iOS 13 or later.

## Requirements

- iOS 13.0 or later
- macOS 10.15 or later
- Xcode 11.0 or later

## Installation

There are four ways to use ModernRIBs in your project:

- using CocoaPods
- using Swift Package Manager
- manual install (build frameworks or embed Xcode Project)

#### CocoaPods

To integrate ModernRIBs into your project add the following to your `Podfile`:

```ruby
pod 'ModernRIBs'
```

#### Swift Package Manager

To use Swift Package Manager, you should use Xcode 11+ to open your project. Click `File` -> `Swift Packages` -> `Add Package Dependency`, enter [ModernRIBs URL](https://github.com/DevYeom/ModernRIBs.git). Or you can login Xcode with your GitHub account and just type `ModernRIBs` to search.

After select the package, you can choose the dependency type (tagged version, branch or commit). Then Xcode will setup all the stuff for you.

If you're a framework author and use `ModernRIBs` as a dependency, update your `Package.swift` file:

```
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/DevYeom/ModernRIBs.git", from: "0.0.1")
    ],
    // ...
)
```

## License

ModernRIBs is released under the same Apache License 2.0 as Uber's RIBs. See [License.txt](https://github.com/DevYeom/ModernRIBs/blob/main/LICENSE.txt) for more information.
