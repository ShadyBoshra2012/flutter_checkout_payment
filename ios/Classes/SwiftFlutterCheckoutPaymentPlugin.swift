import Flutter
import Checkout
import UIKit
import Frames

public class SwiftFlutterCheckoutPaymentPlugin: NSObject, FlutterPlugin {

    /// The channel name which it's the bridge between Dart and SWIFT
    private static var CHANNEL_NAME : String = "shadyboshra2012/fluttercheckoutpayment"

    /// Methods name which detect which it called from Flutter.
    private var METHOD_INIT : String = "init"
    private var METHOD_GENERATE_TOKEN : String = "generateToken"
    private var METHOD_GENERATE_APPLE_PAY_TOKEN : String = "generateApplePayToken"
    private var METHOD_IS_CARD_VALID : String = "isCardValid"
    private var METHOD_HANDLE_3DS : String = "handle3DS"

    /// Error codes returned to Flutter if there's an error.
    private var GENERATE_TOKEN_ERROR : String = "2"

    /// Checkout API iOS Platform
    private var checkoutAPIClient : Frames.CheckoutAPIService! = nil

    private var currentFlutterResult: FlutterResult? = nil

    private var environment: Frames.Environment!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCheckoutPaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == METHOD_INIT {

            // Get the args from Flutter.
            guard let args = call.arguments as? [String: Any] else {
                return
            }

            let key : String = args["key"] as! String
            let environmentString : String = args["environment"] as! String

            environment = environmentString == "Environment.SANDBOX" ? Frames.Environment.sandbox : Frames.Environment.live
            // Init Checkout API
            checkoutAPIClient = CheckoutAPIService(publicKey: key, environment: environment)

            // Return true if success.
            result(true)
        }
        else if call.method == METHOD_GENERATE_TOKEN {
            // Get the args from Flutter.
            let args = call.arguments as? [String: Any]

            let cardNumber : String = args!["number"] as! String
            let name : String = args!["name"] as! String
            let expiryMonth : String = args!["expiryMonth"] as! String
            let expiryMonthInt = Int(expiryMonth)!
            let expiryYear : String = args!["expiryYear"] as! String
            let expiryYearInt = Int(expiryYear)!
            let cvv : String = args!["cvv"] as! String

            // Init card without billing address / phone number
            // if not found and generate token.
            guard let billingModelDictionary = args!["billingModel"] as? [String: Any], let phoneModelDictionary = billingModelDictionary["phoneModel"] as? [String: Any] else {
                let card = Card(number: cardNumber, expiryDate: ExpiryDate(month: expiryMonthInt, year: expiryYearInt), name: name, cvv: cvv, billingAddress: nil, phone: nil)

                // create the card token request
                checkoutAPIClient.createToken(.card(card)) { createTokenResult in
                    do {
                        switch createTokenResult {
                        case let .success(tokenDetails):
                            let tokenResponse = try self.tokenDetailsToTokenisationResponseString(tokenDetails: tokenDetails)
                            result(tokenResponse)
                        case .failure(let ex):
                            result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: ex.localizedDescription, details: nil))
                        }
                    } catch {
                        result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: error.localizedDescription, details: nil))
                    }
                }
                return
            }

            let addressLine1 : String = billingModelDictionary["addressLine1"] as! String
            let addressLine2 : String = billingModelDictionary["addressLine2"] as! String
            let city : String = billingModelDictionary["city"] as! String
            let state : String = billingModelDictionary["state"] as! String
            let zip : String = billingModelDictionary["postcode"] as! String
            let country : String = billingModelDictionary["country"] as! String

            let countryCode : String = phoneModelDictionary["countryCode"] as! String
            let phoneNumber : String = phoneModelDictionary["number"] as! String

            // create the phone number
            let phoneModel = Checkout.Phone(number: phoneNumber, country: Country(iso3166Alpha2: countryCode))

            // create the address
            let billingModel = Checkout.Address(addressLine1: addressLine1, addressLine2: addressLine2, city: city, state: state, zip: zip, country: Country(iso3166Alpha2: country))

            // create the card token request and generate the token.
            let card = Card(number: cardNumber, expiryDate: ExpiryDate(month: expiryMonthInt, year: expiryYearInt), name: name, cvv: cvv, billingAddress: billingModel, phone: phoneModel)

            // create the card token request
            checkoutAPIClient.createToken(.card(card), completion: { [self] createTokenResult in
                do {
                    switch createTokenResult {
                    case let .success(tokenDetails):
                        let tokenResponse = try self.tokenDetailsToTokenisationResponseString(tokenDetails: tokenDetails)
                        result(tokenResponse)
                    case .failure(let ex):
                        result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: ex.localizedDescription, details: nil))
                    }
                } catch {
                    result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: error.localizedDescription, details: nil))
                }
            })
        }
        else if call.method == METHOD_GENERATE_APPLE_PAY_TOKEN {
            // Get the args from Flutter.
            let args = call.arguments as! [String: Any]
            let paymentDataBase64 : String = args["paymentDataBase64"] as! String
            let paymentData = Data(base64Encoded: paymentDataBase64)!

            // Request an Apple Pay token.
            checkoutAPIClient.createToken(.applePay(ApplePay(tokenData: paymentData))) { createTokenResult in
                switch createTokenResult {
                case .success(let tokenDetails):
                    do {
                        let tokenResponse = try self.tokenDetailsToTokenisationResponseString(tokenDetails: tokenDetails)
                        result(tokenResponse)
                    } catch {
                        result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: error.localizedDescription, details: nil))
                    }
                case .failure(let error):
                    result(FlutterError(code: self.GENERATE_TOKEN_ERROR, message: error.localizedDescription, details: nil))
                }
            }
        }
        else if call.method == METHOD_IS_CARD_VALID {

            // Get the args from Flutter.
            let args = call.arguments as? [String: Any]

            let cardNumber : String = args!["number"] as! String

            var checkoutEnv: Checkout.Environment = .sandbox
            if (environment == .live) {
                checkoutEnv = .production
            }
            /// verify card number
            let cardValidator = CardValidator(environment: checkoutEnv)
            let isCardValid = cardValidator.validate(cardNumber: cardNumber)
            switch isCardValid {
            case .success:
                result(true)
            case .failure:
                result(false)
            }
        }
        else if call.method == METHOD_HANDLE_3DS {
            currentFlutterResult = result

            let args = call.arguments as? [String: Any]

            let successUrl : String = args!["successUrl"] as! String
            let failUrl : String = args!["failUrl"] as! String
            let authUrl : String = args!["authUrl"] as! String

            let threeDSWebViewController = ThreedsWebViewController.init(
                environment: environment, successUrl: URL(string: successUrl)!,
                failUrl: URL(string: failUrl)!)
            threeDSWebViewController.authURL = URL(string: authUrl)
            threeDSWebViewController.delegate = self

            let rootViewController: UIViewController! = UIApplication.shared.windows.first { $0.isKeyWindow}?.rootViewController

            var navigationController: UINavigationController! = nil
            if (rootViewController is UINavigationController) {
                navigationController = rootViewController as? UINavigationController
            } else {
                navigationController = UINavigationController(rootViewController: threeDSWebViewController)
            }

            navigationController.presentationController?.delegate = self
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }

    fileprivate func tokenDetailsToTokenisationResponseString(tokenDetails: TokenDetails) throws -> String {
        var billingAddress: BillingAddress? = nil
        if let responseBillingAddress = tokenDetails.billingAddress {
            billingAddress = BillingAddress(addressLine1: responseBillingAddress.addressLine1, addressLine2: responseBillingAddress.addressLine2, postcode: responseBillingAddress.zip, country: responseBillingAddress.country?.iso3166Alpha2, city: responseBillingAddress.city, state: responseBillingAddress.state)
        }

        var phone: Phone? = nil
        if let responsePhoneNumber = tokenDetails.phone {
            phone = Phone(countryCode: responsePhoneNumber.countryCode, number: responsePhoneNumber.number)
        }

        let response = CardTokenisationResponse(type: tokenDetails.type.rawValue, token: tokenDetails.token, expiresOn: tokenDetails.expiresOn, expiryMonth: tokenDetails.expiryDate.month, expiryYear: tokenDetails.expiryDate.year, scheme: tokenDetails.scheme, last4: tokenDetails.last4, cardType: tokenDetails.cardType, cardCategory: tokenDetails.cardCategory, issuer: tokenDetails.issuer, issuerCountry: tokenDetails.issuerCountry, productId: tokenDetails.productId, productType: tokenDetails.productType, name: tokenDetails.name, billingAddress: billingAddress, phone: phone)

        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(response)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        return json!
    }
}

extension SwiftFlutterCheckoutPaymentPlugin: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // user dismissed the sheet, treat as failure
        if let result = currentFlutterResult {
            result(nil)
            currentFlutterResult = nil
        }
    }
}

extension SwiftFlutterCheckoutPaymentPlugin: ThreedsWebViewControllerDelegate {

    public func threeDSWebViewControllerAuthenticationDidSucceed(_ threeDSWebViewController: ThreedsWebViewController, token: String?) {
        // Handle successful 3DS.
        let rootViewController: UIViewController! = UIApplication.shared.windows.first { $0.isKeyWindow}?.rootViewController
        rootViewController.dismiss(animated: true)

        if let result = currentFlutterResult {
            result(token)
            currentFlutterResult = nil
        }
    }

    public func threeDSWebViewControllerAuthenticationDidFail(_ threeDSWebViewController: ThreedsWebViewController) {
        // Handle failed 3DS.
        let rootViewController: UIViewController! = UIApplication.shared.windows.first { $0.isKeyWindow}?.rootViewController
        rootViewController.dismiss(animated: true)

        if let result = currentFlutterResult {
            result(nil)
            currentFlutterResult = nil
        }
    }

}
