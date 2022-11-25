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
  static const String METHOD_HANDLE_3DS = "handle3DS";

  /// Error codes returned to Flutter if there's an error.
  static const String INIT_ERROR = "1";
  static const String GENERATE_TOKEN_ERROR = "2";
  static const String IS_CARD_VALID_ERROR = "3";
  static const String HANDLE_3DS_ERROR = "4";

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
      throw FlutterCheckoutException.fromPlatformException(e);
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
      throw FlutterCheckoutException.fromPlatformException(e);
    }
  }

  /// Check if card number is valid.
  ///
  /// [number] The card number.
  static Future<bool?> isCardValid({required String number}) async {
    try {
      return await _channel.invokeMethod(METHOD_IS_CARD_VALID, <String, String>{'number': number});
    } on PlatformException catch (e) {
      throw FlutterCheckoutException.fromPlatformException(e);
    }
  }

  /// Open a WebView to allow the user to pass a 3DS challenge.
  /// success and failUrl should match what you have configured elsewhere!
  ///
  /// [authUrl] the 3DS challenge URL received from Checkout.
  /// [successUrl] If the issuer redirects to this url, we will return the token.
  /// [failUrl] If the issuer redirects to this url, we will return null.
  static Future<String?> handle3DS(
      {required String authUrl, required String successUrl, required String failUrl}) async {
    try {
      return await _channel.invokeMethod(
          METHOD_HANDLE_3DS, <String, String>{
        'successUrl': successUrl,
        'failUrl': failUrl,
        'authUrl': authUrl
      });
    } on PlatformException catch (e) {
      throw FlutterCheckoutException.fromPlatformException(e);
    }
  }
  
}

enum FlutterCheckoutExceptionCode {
  SDK_INITIALIZATION_ERROR,
  TOKEN_GENERATION_ERROR,
  CARD_NUMBER_VALIDATION_ERROR,
  HANDLE_3DS_ERROR,
  UNEXPECTED_ERROR,
}

class FlutterCheckoutException implements Exception {
  const FlutterCheckoutException([
    this.code = FlutterCheckoutExceptionCode.UNEXPECTED_ERROR,
    this.message =
    'An unknown error occurred.',
    this.details = null,
  ]);

  factory FlutterCheckoutException.fromPlatformException(
      PlatformException platformException) {
    switch (platformException.code) {
      case FlutterCheckoutPayment.INIT_ERROR:
        return FlutterCheckoutException(
          FlutterCheckoutExceptionCode.SDK_INITIALIZATION_ERROR,
          platformException.message,
          platformException.details,
        );
      case FlutterCheckoutPayment.GENERATE_TOKEN_ERROR:
        return FlutterCheckoutException(
          FlutterCheckoutExceptionCode.TOKEN_GENERATION_ERROR,
          platformException.message,
          platformException.details,
        );
      case FlutterCheckoutPayment.IS_CARD_VALID_ERROR:
        return FlutterCheckoutException(
          FlutterCheckoutExceptionCode.CARD_NUMBER_VALIDATION_ERROR,
          platformException.message,
          platformException.details,
        );
      case FlutterCheckoutPayment.HANDLE_3DS_ERROR:
        return FlutterCheckoutException(
          FlutterCheckoutExceptionCode.HANDLE_3DS_ERROR,
          platformException.message,
          platformException.details,
        );
      default:
        return const FlutterCheckoutException();
    }
  }

  final FlutterCheckoutExceptionCode code;

  final String? message;

  final dynamic details;

  @override
  String toString() {
    return "$message";
  }
}
