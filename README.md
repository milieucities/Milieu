# Milieu

## INTRODUCTION
Welcome on board! You are invited to develope a exiciting mobile app for the future. More
information can be found on [MILIEU](http://www.milieu.io/ "MILIEU")


## DEVELOPMENT NOTICE
1. Please open the `Milieu.xcworspace` to develop the app instead of `Milieu.xcodeproj`. This is 
because that we are using CocoaPod to manage the open source frameworks and libraries. Read more
about the [CocoaPod](https://cocoapods.org/ "CocoaPod")

## RUN MILIEU LOCALLY
1. Download the repo to local directory. 
2. Install the CocoaPods following their [installation guide](https://guides.cocoapods.org/using/getting-started.html).
3. In the terminal, under the directory where Podfile is available, run `bundle exec pod install`. 
(Each time you checkout a new branch)
4. Open the `Milieu.xcworspace`.
5. Follow [this answer](http://stackoverflow.com/a/37732248) to build the Pod with Pod schemes.
6. Build the app and run in simulator or device

## DISTRIBUTE ALPHA/BETA VERSION IN TESTFLIGHT
1. Following the [tutorial](https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile) if
you didn't install the bundler. 
2. Don't need to recreate the gemfile which is already exist, run `bundle exec fastlane beta`.

## DEVELOPMENT NOTICE
1. Please open the `Milieu.xcworspace` to develop the app instead of `Milieu.xcodeproj`. This is 
because that we are using CocoaPod to manage the open source frameworks and libraries. Read more
about the [CocoaPod](https://cocoapods.org/ "CocoaPod")

2. This repository contains all your certificates and provisioning profiles needed to build and sign your applications. They are encrypted using OpenSSL via a passphrase.

**Important:** Make sure this repository is set to private and only your team members have access to this repo.

Do not modify this file, as it gets overwritten every time you run `match`.

## [fastlane match](https://github.com/fastlane/fastlane/tree/master/match#readme)



### Install [fastlane match](https://github.com/fastlane/fastlane/tree/master/match#readme)

```
sudo gem install match
```

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

### Usage

Navigate to your project folder and run

```
match appstore
```
```
match adhoc
```
```
match development
```

For more information open [fastlane match git repo](https://github.com/fastlane/fastlane/tree/master/match#readme)

### Content

#### certs

This directory contains all your certificates with their private keys

#### profiles

This directory contains all provisioning profiles

------------------------------------

For more information open [fastlane match git repo](https://github.com/fastlane/fastlane/tree/master/match#readme)
