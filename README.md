# Flutter Checkout Payment  

[![pub.dev](https://img.shields.io/pub/v/flutter_checkout_payment.svg)](https://pub.dev/packages/flutter_checkout_payment)  [![Donate Paypal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/ShadyBoshra2012) [![GitHub Follow](https://img.shields.io/github/followers/ShadyBoshra2012.svg?style=social&label=Follow)](https://github.com/ShadyBoshra2012)

## Explain

This plugin is for [Checkout](https://checkout.com) online payment. It's implemented the native SDKs to work on Flutter environment.

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_checkout_payment: ^0.1.0+2
```

### Android

You have to edit `AndroidManifest.xml` file with following.

```manifest
<manifest ...
    xmlns:tools="http://schemas.android.com/tools" 
    ... />
    ...
    <application
        ...
        tools:replace="android:label" 
        ... >
    ...
    </appliaction>
</manifest>
```

### iOS

The SDK build for >= iOS 10.0, so you need to set the platform version in the `Podfile` to iOS 10 or above.

```
platform: :ios, '10.0'
```

## Usage

You just have to import the package with

```dart
import 'package:flutter_checkout_payment/flutter_checkout_payment.dart';
```

Then, you need to initialize the API with you public key. Your public key is found on Checkout dashboard.

```dart
await FlutterCheckoutPayment.init(key: "YOUR_PUBLIC_KEY");
```

And when you are ready for production you have to set the environment to Live.

```dart
await FlutterCheckoutPayment.init(key: "YOUR_PUBLIC_KEY", environment: Environment.LIVE);
```

Now, you can generate the Token which you will use to proceed the payment.

```dart
String token = await FlutterCheckoutPayment.generateToken(number: "4242424242424242", name: "name", expiryMonth: "05", expiryYear: "21", cvv: "100");
```

## Public Static Methods Summary

| Return                    | Description |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Future\<bool> | **init(@required String key, Environment environment** *default* **Environment.SANDBOX})** <br>Initialize the Checkout API with key and environment. Return a bool of the successful status.|
| Future\<String> | **generateToken({@required String number, @required String name, @required String expiryMonth, @required String expiryYear, @required String cvv, BillingModel billingModel})** <br>Generate the token which it will be used to make the payment, return the String value.|
| Future\<bool> | **isCardValid({@required String number})** <br>Check whether the card number is valid or not, return a bool with the result.|

The rest of methods are under development.

## Objects

```dart
class BillingModel {
  final String addressLine1;
  final String addressLine2;
  final String postcode;
  final String country;
  final String city;
  final String state;
  final PhoneModel phoneModel;
}

class PhoneModel {
  final String countryCode;
  final String number;
}
```

## Links

Checkout Android SDK: https://github.com/checkout/frames-android

Checkout iOS SDK: https://github.com/checkout/frames-ios

This plugin is mainly developed for [GRANDTK](http://grandtk.com/) company.

## Issues or Contributions

This is a beta version of plugin, so I am very appreciated for any issues or contribution you can help me with.

## License

MIT: [http://mit-license.org](http://mit-license.org). 

Copyright (c) 2019 Shady Boshra. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Find me on Stackoverflow

<a href="https://stackoverflow.com/users/2076880/shady-boshra"><img src="https://stackoverflow.com/users/flair/2076880.png" width="208" height="58" alt="profile for Shady Boshra at Stack Overflow, Q&amp;A for professional and enthusiast programmers" title="profile for Shady Boshra at Stack Overflow, Q&amp;A for professional and enthusiast programmers"></a>