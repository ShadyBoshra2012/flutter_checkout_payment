part of 'package:flutter_checkout_payment/flutter_checkout_payment.dart';

class CardTokenisationResponse {
  String? type;
  String? token;
  String? expiresOn;
  int? expiryMonth;
  int? expiryYear;
  String? scheme;
  String? last4;
  String? bin;
  String? cardType;
  String? cardCategory;
  String? issuer;
  String? issuerCountry;
  String? productId;
  String? productType;
  BillingModel? billingAddress;
  PhoneModel? phone;
  String? name;

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
}
