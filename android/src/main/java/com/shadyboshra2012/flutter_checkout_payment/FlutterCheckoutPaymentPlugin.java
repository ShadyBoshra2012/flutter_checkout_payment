package com.shadyboshra2012.flutter_checkout_payment;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import com.android.volley.VolleyError;
import com.checkout.android_sdk.CheckoutAPIClient;
import com.checkout.android_sdk.Models.BillingModel;
import com.checkout.android_sdk.Models.PhoneModel;
import com.checkout.android_sdk.Request.CardTokenisationRequest;
import com.checkout.android_sdk.Response.CardTokenisationFail;
import com.checkout.android_sdk.Response.CardTokenisationResponse;
import com.checkout.android_sdk.Utils.CardUtils;
import com.checkout.android_sdk.Utils.Environment;
import com.google.gson.Gson;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterCheckoutPaymentPlugin
 */
public class FlutterCheckoutPaymentPlugin implements FlutterPlugin, MethodCallHandler {
    /// The channel name which it's the bridge between Dart and JAVA
    private static final String CHANNEL_NAME = "shadyboshra2012/fluttercheckoutpayment";

    /// Methods name which detect which it called from Flutter.
    private static final String METHOD_INIT = "init";
    private static final String METHOD_GENERATE_TOKEN = "generateToken";
    private static final String METHOD_IS_CARD_VALID = "isCardValid";

    /// Error codes returned to Flutter if there's an error.
    private static final String INIT_ERROR = "1";
    private static final String GENERATE_TOKEN_ERROR = "2";
    private static final String IS_CARD_VALID_ERROR = "3";

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    /// Context to hold it for Payment SDK needs.
    @SuppressLint("StaticFieldLeak")
    private static Context context;

    /// Variable to hold the result object when it need to coded inside callbacks.
    private Result pendingResult;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new FlutterCheckoutPaymentPlugin());
        context = registrar.context();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case METHOD_INIT:
                try {
                    // Get the args from Flutter.
                    String key = call.argument("key");
                    String environmentString = call.argument("environment");
                    assert environmentString != null;
                    Environment environment = (environmentString.equals("Environment.SANDBOX"))
                            ? Environment.SANDBOX : Environment.LIVE;

                    // Init Checkout API
                    mCheckoutAPIClient = new CheckoutAPIClient(
                            context,                // context
                            key,                   // your public key
                            environment   // the environment
                    );
                    // Set callbacks listeners.
                    mCheckoutAPIClient.setTokenListener(mTokenListener); // pass the callback

                    // Return true for a success.
                    result.success(true);
                } catch (Exception ex) {
                    // Return an error.
                    result.error(INIT_ERROR, ex.getMessage(), ex.getLocalizedMessage());
                }
                break;
            case METHOD_GENERATE_TOKEN:
                try {
                    // Set pendingResult to result to use it in callbacks.
                    pendingResult = result;

                    // Get the args from Flutter.
                    String cardNumber = call.argument("number");
                    String name = call.argument("name");
                    String expiryMonth = call.argument("expiryMonth");
                    String expiryYear = call.argument("expiryYear");
                    String cvv = call.argument("cvv");

                    // Init cardTokenisationRequest without billing model.
                    CardTokenisationRequest cardTokenisationRequest = new CardTokenisationRequest(
                            cardNumber, name, expiryMonth, expiryYear, cvv);

                    // Check if billing model is set from Flutter.
                    HashMap<String, Object> billingModelMap = call.argument("billingModel");

                    if (billingModelMap != null && billingModelMap.containsKey("phoneModel")) {
                        String addressLine1 = billingModelMap.get("addressLine1").toString();
                        String addressLine2 = billingModelMap.get("addressLine2").toString();
                        String postcode = billingModelMap.get("postcode").toString();
                        String country = billingModelMap.get("country").toString();
                        String city = billingModelMap.get("city").toString();
                        String state = billingModelMap.get("state").toString();

                        HashMap<String, Object> phoneModelMap = (HashMap<String, Object>) billingModelMap.get("phoneModel");
                        assert phoneModelMap != null;
                        String countryCode = phoneModelMap.get("countryCode").toString();
                        String phoneNumber = phoneModelMap.get("number").toString();

                        BillingModel billingModel = new BillingModel(
                                addressLine1,
                                addressLine2,
                                postcode,
                                country,
                                city,
                                state
                        );

                        PhoneModel phoneModel = new PhoneModel(
                                countryCode,
                                phoneNumber
                        );

                        // Set cardTokenisationRequest with billing model.
                        cardTokenisationRequest =
                                new CardTokenisationRequest(cardNumber, name, expiryMonth, expiryYear, cvv,
                                        billingModel, phoneModel);
                    }

                    // Generate the token.
                    mCheckoutAPIClient.generateToken(cardTokenisationRequest);
                } catch (Exception ex) {
                    // Return error.
                    result.error(GENERATE_TOKEN_ERROR, ex.getMessage(), ex.getLocalizedMessage());
                }
                break;
            case METHOD_IS_CARD_VALID:
                try {
                    // Get the args from Flutter.
                    String cardNumber = call.argument("number");

                    // verify card number
                    boolean isCardValid = CardUtils.isValidCard(cardNumber);

                    // Return the boolean result.
                    result.success(isCardValid);
                    ;
                } catch (Exception ex) {
                    // Return an error.
                    result.error(IS_CARD_VALID_ERROR, ex.getMessage(), ex.getLocalizedMessage());
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    /*** Checkout Android Platform ***/
    private CheckoutAPIClient mCheckoutAPIClient;

    private CheckoutAPIClient.OnTokenGenerated mTokenListener = new CheckoutAPIClient.OnTokenGenerated() {
        @Override
        public void onTokenGenerated(CardTokenisationResponse token) {
            // Using Gson to convert the custom request object into a JSON string for use in the resonse.
            Gson gson = new Gson();
            pendingResult.success(gson.toJson(token));
        }

        @Override
        public void onError(CardTokenisationFail error) {
            pendingResult.error(error.getErrorCodes()[0], error.getErrorType(), error.getRequestId());
        }

        @Override
        public void onNetworkError(VolleyError error) {
            // your network error
            pendingResult.error(error.networkResponse.statusCode + "", error.getMessage(),
                    error.getNetworkTimeMs());
        }
    };
    /*** Checkout Android Platform ***/
}
