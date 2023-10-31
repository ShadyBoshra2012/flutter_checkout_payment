// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'package:flutter_checkout_payment/flutter_checkout_payment.dart';

class CardTokenisationResponse {
  final String? type;
  final String? token;
  final String? expiresOn;
  final int? expiryMonth;
  final int? expiryYear;
  final String? scheme;
  final String? last4;
  final String? bin;
  final String? cardType;
  final String? cardCategory;
  final String? issuer;
  final String? issuerCountry;
  final String? productId;
  final String? productType;
  final BillingModel? billingAddress;
  final PhoneModel? phone;
  final String? name;

  CardTokenisationResponse({
    this.type,
    this.token,
    this.expiresOn,
    this.expiryMonth,
    this.expiryYear,
    this.scheme,
    this.last4,
    this.bin,
    this.cardType,
    this.cardCategory,
    this.issuer,
    this.issuerCountry,
    this.productId,
    this.productType,
    this.billingAddress,
    this.phone,
    this.name,
  });

  factory CardTokenisationResponse.fromJSON(Map<String, dynamic> data) {
    return CardTokenisationResponse(
      bin: data["bin"],
      cardCategory: data["card_category"],
      cardType: data["card_type"],
      expiresOn: data["expires_on"],
      expiryMonth: data["expiry_month"],
      expiryYear: data["expiry_year"],
      issuerCountry: data["issuer_country"],
      last4: data["last4"],
      name: data["name"],
      productId: data["product_id"],
      productType: data["product_type"],
      scheme: data["scheme"],
      token: data["token"],
      type: data["type"],
    );
  }

  factory CardTokenisationResponse.fromString(String str) {
    Map<String, dynamic> data = json.decode(str);
    return CardTokenisationResponse.fromJSON(data);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'token': token,
      'expiresOn': expiresOn,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'scheme': scheme,
      'last4': last4,
      'bin': bin,
      'cardType': cardType,
      'cardCategory': cardCategory,
      'issuer': issuer,
      'issuerCountry': issuerCountry,
      'productId': productId,
      'productType': productType,
      'billingAddress': billingAddress?.toMap(),
      'phone': phone?.toMap(),
      'name': name,
    };
  }
}
