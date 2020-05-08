import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'models/BillingModel.dart';

enum Environment { SANDBOX, LIVE }

class FlutterCheckoutPayment {
  /// The channel name which it's the bridge between Dart and JAVA or SWIFT
  static const String CHANNEL_NAME = "shadyboshra2012/fluttercheckoutpayment";

  /// Methods name which detect which it called from Flutter.
  static const String METHOD_INIT = "init";
  static const String METHOD_GENERATE_TOKEN = "generateToken";
  static const String METHOD_IS_CARD_VALID = "isCardValid";

  /// Error codes returned to Flutter if there's an error.
  static const String INIT_ERROR = "1";
  static const String GENERATE_TOKEN_ERROR = "2";
  static const String IS_CARD_VALID_ERROR = "3";

  /// Initialize the channel
  static const MethodChannel _channel = const MethodChannel(CHANNEL_NAME);

  /// Initialize Checkout.com payment SDK.
  /// [key] public sdk key.
  /// [environment] the environment of initialization { SANDBOX, LIVE }, default SANDBOX.
  static Future<bool> init(
      {@required String key,
      Environment environment = Environment.SANDBOX}) async {
    try {
      return await _channel.invokeMethod(METHOD_INIT,
          <String, String>{'key': key, 'environment': environment.toString()});
    } on PlatformException catch (e) {
      if (e.code == INIT_ERROR)
        throw "Error Occured: Code: $INIT_ERROR. Message: ${e.message}. Details: SDK Initializtion Error";
      throw "Error Occured: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }

  /// Generate Token.
  /// [number] The card number.
  /// [name] The card holder name.
  /// [expiryMonth] The expiration month.
  /// [expiryYear] The expiration year.
  /// [cvv] The cvv behind the card.
  /// [billingModel] The billing model of the card.
  static Future<String> generateToken(
      {@required String number,
      @required String name,
      @required String expiryMonth,
      @required String expiryYear,
      @required String cvv,
      BillingModel billingModel}) async {
    try {
      if (billingModel == null) {
        // Send args without billing model
        final String token =
            await _channel.invokeMethod(METHOD_GENERATE_TOKEN, <String, String>{
          'number': number,
          'name': name,
          'expiryMonth': expiryMonth,
          'expiryYear': expiryYear,
          'cvv': cvv
        });
        return token;
      } else {
        // Send args with billing model
        final String token =
            await _channel.invokeMethod(METHOD_GENERATE_TOKEN, <String, Object>{
          'number': number,
          'name': name,
          'expiryMonth': expiryMonth,
          'expiryYear': expiryYear,
          'cvv': cvv,
          'billingModel': billingModel.toMap()
        });
        return token;
      }
    } on PlatformException catch (e) {
      if (e.code == GENERATE_TOKEN_ERROR)
        throw "Error Occured: Code: $GENERATE_TOKEN_ERROR. Message: ${e.message}. Details: Generating Token Error";
      throw "Error Occured: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }

  /// Check if card number is valid.
  /// [number] The card number.
  static Future<bool> isCardValid({@required String number}) async {
    try {
      return await _channel.invokeMethod(
          METHOD_IS_CARD_VALID, <String, String>{'number': number});
    } on PlatformException catch (e) {
      if (e.code == IS_CARD_VALID_ERROR)
        throw "Error Occured: Code: $IS_CARD_VALID_ERROR. Message: ${e.message}. Details: Validation Card Number Error";
      throw "Error Occured: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }
}
