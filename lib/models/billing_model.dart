part of 'package:flutter_checkout_payment/flutter_checkout_payment.dart';

class BillingModel {
  final String addressLine1;
  final String addressLine2;
  final String postcode;
  final String country;
  final String city;
  final String state;
  final PhoneModel phoneModel;

  BillingModel(
      {required this.addressLine1,
      required this.addressLine2,
      required this.postcode,
      required this.country,
      required this.city,
      required this.state,
      required this.phoneModel});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "addressLine1": this.addressLine1,
      "addressLine2": this.addressLine2,
      "postcode": this.postcode,
      "country": this.country,
      "city": this.city,
      "state": this.state,
      "phoneModel": this.phoneModel.toMap()
    };
  }
}
