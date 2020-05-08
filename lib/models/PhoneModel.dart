import 'package:flutter/cupertino.dart';

class PhoneModel {
  final String countryCode;
  final String number;

  PhoneModel({@required this.countryCode, @required this.number});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"countryCode": this.countryCode, "number": this.number};
  }
}
