import 'dart:async';

import 'package:credit_card/credit_card_form.dart';
import 'package:credit_card/credit_card_model.dart';
import 'package:credit_card/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_checkout_payment/flutter_checkout_payment.dart';
import 'package:flutter_checkout_payment/models/BillingModel.dart';
import 'package:flutter_checkout_payment/models/PhoneModel.dart';

import 'Keys.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _isInit = "false";

  String cardNumber = '';
  String expiryDate = '';
  String cardNameHolder = '';
  String cvv = '';
  bool cvvFocused = false;

  @override
  void initState() {
    super.initState();
    initPaymentSDK();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPaymentSDK() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool isSuccess = await FlutterCheckoutPayment.init(key: "${Keys.TEST_KEY}");
      //bool isSuccess =  await FlutterCheckoutPayment.init(key: "${Keys.TEST_KEY}", environment: Environment.LIVE);
      print(isSuccess);
      if (mounted) setState(() => _isInit = "true");
    } on PlatformException {
      if (mounted) setState(() => _isInit = "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Checkout Payment Plugin'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Text("Checkout Init: $_isInit", style: TextStyle(fontSize: 18)),
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardNameHolder,
                cvvCode: cvv,
                showBackView: cvvFocused,
                height: 180,
                width: 305,
                animationDuration: Duration(milliseconds: 1000),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CreditCardForm(onCreditCardModelChange: _onModelChange),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                  RaisedButton(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Generate Token",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        )),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: _generateToken,
                  ),
                  RaisedButton(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Card Validation",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        )),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: _cardValidation,
                  )
                ]),
                RaisedButton(
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Generate Token with Address",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      )),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: _generateTokenWithAddress,
                )
              ]),
              SizedBox(height: 10)
            ],
          ),
        ));
  }

  void _onModelChange(CreditCardModel model) {
    setState(() {
      cardNumber = model.cardNumber;
      expiryDate = model.expiryDate;
      cardNameHolder = model.cardHolderName;
      cvv = model.cvvCode;
      cvvFocused = model.isCvvFocused;
    });
  }

  Future<void> _generateToken() async {
    try {
      // Show loading dialog
      showDialog(
          context: this.context,
          barrierDismissible: false,
          child: WillPopScope(
              onWillPop: () => Future<bool>.value(false),
              child: AlertDialog(
                title: Text("Loading..."),
                content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[CircularProgressIndicator()]),
              )));

      String number = cardNumber.replaceAll(" ", "");
      String expiryMonth = expiryDate.substring(0, 2);
      String expiryYear = expiryDate.substring(3);

      print("$cardNumber, $cardNameHolder, $expiryMonth, $expiryYear, $cvv");

      String token = await FlutterCheckoutPayment.generateToken(
          number: number, name: cardNameHolder, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv);

      // Hide loading dialog
      Navigator.pop(context);

      // Show result dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Token"),
            content: Text("$token"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    } catch (ex) {
      // Hide loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Error"),
            content: Text("${ex.toString()}"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    }
  }

  Future<void> _generateTokenWithAddress() async {
    try {
      // Show loading dialog
      showDialog(
          context: this.context,
          barrierDismissible: false,
          child: WillPopScope(
              onWillPop: () => Future<bool>.value(false),
              child: AlertDialog(
                title: Text("Loading..."),
                content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[CircularProgressIndicator()]),
              )));

      String number = cardNumber.replaceAll(" ", "");
      String expiryMonth = expiryDate.substring(0, 2);
      String expiryYear = expiryDate.substring(3);

      print("$cardNumber, $cardNameHolder, $expiryMonth, $expiryYear, $cvv");

      String token = await FlutterCheckoutPayment.generateToken(
          number: number,
          name: cardNameHolder,
          expiryMonth: expiryMonth,
          expiryYear: expiryYear,
          cvv: cvv,
          billingModel: BillingModel(
              addressLine1: "address line 1",
              addressLine2: "address line 2",
              postcode: "postcode",
              country: "UK",
              city: "city",
              state: "state",
              phoneModel: PhoneModel(countryCode: "+44", number: "07123456789")));

      // Hide loading dialog
      Navigator.pop(context);

      // Show result dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Token"),
            content: Text("$token"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    } catch (ex) {
      // Hide loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Error"),
            content: Text("${ex.toString()}"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    }
  }

  Future<void> _cardValidation() async {
    try {
      // Show loading dialog
      showDialog(
          context: this.context,
          barrierDismissible: false,
          child: WillPopScope(
              onWillPop: () => Future<bool>.value(false),
              child: AlertDialog(
                title: Text("Loading..."),
                content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[CircularProgressIndicator()]),
              )));

      String number = cardNumber.replaceAll(" ", "");

      print("$cardNumber");

      bool isValid = await FlutterCheckoutPayment.isCardValid(number: number);

      // Hide loading dialog
      Navigator.pop(context);

      // Show result dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Validation? "),
            content: Text("$isValid"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    } catch (ex) {
      // Hide loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
          context: this.context,
          child: AlertDialog(
            title: Text("Error"),
            content: Text("${ex.toString()}"),
            actions: <Widget>[FlatButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
    }
  }
}
