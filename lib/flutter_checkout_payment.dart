import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

part 'package:flutter_checkout_payment/models/billing_model.dart';
part 'package:flutter_checkout_payment/models/card_tokenisation_response.dart';
part 'package:flutter_checkout_payment/models/phone_model.dart';

enum Environment { SANDBOX, LIVE }

class FlutterCheckoutPayment {
  /// The channel name which it's the bridge between Dart and JAVA or SWIFT.
  static const String CHANNEL_NAME = "shadyboshra2012/fluttercheckoutpayment";

  /// Methods name which detect which it called from Flutter.
  static const String METHOD_INIT = "init";
  static const String METHOD_GENERATE_TOKEN = "generateToken";
  static const String METHOD_IS_CARD_VALID = "isCardValid";
  static const String METHOD_HANDLE_THREE_DS_CHALLENGE = "handleThreeDSChallenge";

  /// Error codes returned to Flutter if there's an error.
  static const String INIT_ERROR = "1";
  static const String GENERATE_TOKEN_ERROR = "2";
  static const String IS_CARD_VALID_ERROR = "3";

  /// Initialize the channel
  static const MethodChannel _channel = const MethodChannel(CHANNEL_NAME);

  /// Initialize Checkout.com payment SDK.
  ///
  /// [key] public sdk key.
  /// [environment] the environment of initialization { SANDBOX, LIVE }, default SANDBOX.
  static Future<bool?> init({required String key, Environment environment = Environment.SANDBOX}) async {
    try {
      return await _channel.invokeMethod(METHOD_INIT, <String, String>{'key': key, 'environment': environment.toString()});
    } on PlatformException catch (e) {
      if (e.code == INIT_ERROR)
        throw "Error Occurred: Code: $INIT_ERROR. Message: ${e.message}. Details: SDK Initialization Error";
      throw "Error Occurred: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }

  /// Generate Token.
  ///
  /// [number] The card number.
  /// [name] The card holder name.
  /// [expiryMonth] The expiration month.
  /// [expiryYear] The expiration year.
  /// [cvv] The cvv behind the card.
  /// [billingModel] The billing model of the card.
  static Future<CardTokenisationResponse?> generateToken({
    required String number,
    required String name,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    BillingModel? billingModel,
  }) async {
    try {
      final String stringJSON = await _channel.invokeMethod(METHOD_GENERATE_TOKEN, <String, dynamic>{
        'number': number,
        'name': name,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'billingModel': billingModel?.toMap(),
      });
      return CardTokenisationResponse.fromString(stringJSON);
    } on PlatformException catch (e) {
      if (e.code == GENERATE_TOKEN_ERROR)
        throw "Error Occurred: Code: $GENERATE_TOKEN_ERROR. Message: ${e.message}. Details: Generating Token Error";
      throw "Error Occurred: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }

  /// Check if card number is valid.
  ///
  /// [number] The card number.
  static Future<bool?> isCardValid({required String number}) async {
    try {
      return await _channel.invokeMethod(METHOD_IS_CARD_VALID, <String, String>{'number': number});
    } on PlatformException catch (e) {
      if (e.code == IS_CARD_VALID_ERROR)
        throw "Error Occurred: Code: $IS_CARD_VALID_ERROR. Message: ${e.message}. Details: Validation Card Number Error";
      throw "Error Occurred: Code: ${e.code}. Message: ${e.message}. Details: ${e.details}";
    }
  }

  /// Open a webview to allow the user to pass a 3DS challenge.
  /// sucess and failUrl should match what you have configured elsewhere!
  ///
  /// [authUrl] the 3DS challenge URL received from Checkout.
  /// [sucessUrl] If the issuer redirects to this url, we will return the token.
  /// [failUrl] If the issuer redirects to this url, we will return null.
  static Future<String?> handleThreeDSChallenge(
      {required String authUrl, required String sucessUrl, required String failUrl}) async {
    try {
      return await _channel.invokeMethod(
          METHOD_HANDLE_THREE_DS_CHALLENGE, <String, String>{
        'successUrl': sucessUrl,
        'failUrl': failUrl,
        'authUrl': authUrl
      });
    } on PlatformException catch (e) {
      throw "Error Occurred: Code: ${e.code}. Message: ${e
          .message}. Details: ${e.details}";
    }
  }
  
}
