package com.shadyboshra2012.flutter_checkout_payment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;

import android.view.View;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;

import com.checkout.CardValidatorFactory;
import com.checkout.CheckoutApiServiceFactory;
import com.checkout.api.CheckoutApiService;
import com.checkout.base.model.Country;
import com.checkout.base.model.Environment;
import com.checkout.threedsecure.model.ThreeDSRequest;
import com.checkout.threedsecure.model.ThreeDSResult;
import com.checkout.tokenization.model.*;
import com.checkout.validation.model.ValidationResult;
import com.google.gson.Gson;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import kotlin.Unit;
import org.jetbrains.annotations.NotNull;

/**
 * FlutterCheckoutPaymentPlugin
 */
public class FlutterCheckoutPaymentPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The channel name which it's the bridge between Dart and JAVA
    private static final String CHANNEL_NAME = "shadyboshra2012/fluttercheckoutpayment";

    /// Methods name which detect which it called from Flutter.
    private static final String METHOD_INIT = "init";
    private static final String METHOD_GENERATE_TOKEN = "generateToken";
    private static final String METHOD_GENERATE_GOOGLE_PAY_TOKEN = "generateGooglePayToken";
    private static final String METHOD_IS_CARD_VALID = "isCardValid";
    private static final String METHOD_HANDLE_3DS = "handle3DS";

    /// Error codes returned to Flutter if there's an error.
    private static final String INIT_ERROR = "1";
    private static final String GENERATE_TOKEN_ERROR = "2";
    private static final String IS_CARD_VALID_ERROR = "3";
    private static final String HANDLE_3DS_ERROR = "4";

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private CheckoutApiService mCheckoutAPIClient;

    /// Context to hold it for Payment SDK needs.
    @SuppressLint("StaticFieldLeak")
    private static Context context;

    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onAttachedToActivity(@NonNull @NotNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull @NotNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
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
                        ? Environment.SANDBOX : Environment.PRODUCTION;

                    // Init Checkout API
                    mCheckoutAPIClient = CheckoutApiServiceFactory.create(
                        key,                    // your public key
                        environment,            // the environment
                        context                 // context

                    );

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
                    final Result pendingResult = result;

                    // Get the args from Flutter.
                    String cardNumber = call.argument("number");
                    String name = call.argument("name");
                    String expiryMonth = call.argument("expiryMonth");
                    int expiryMonthInt = Integer.parseInt(expiryMonth);
                    String expiryYear = call.argument("expiryYear");
                    int expiryYearInt = Integer.parseInt(expiryYear);
                    String cvv = call.argument("cvv");

                    // Init cardTokenisationRequest without billing model.
                    Card card = new Card(new ExpiryDate(expiryMonthInt, expiryYearInt), name, cardNumber, cvv, null, null);

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

                        Address address = new Address(
                            addressLine1,
                            addressLine2,
                            city,
                            state,
                            postcode,
                            Country.from(country)
                        );

                        Phone phone = new Phone(
                            phoneNumber,
                            Country.from(countryCode)
                        );

                        // Set card with adress + phone
                        card = new Card(new ExpiryDate(expiryMonthInt, expiryYearInt), name, cardNumber, cvv, address, phone);
                    }

                    // Generate the token.
                    CardTokenRequest cardTokenisationRequest = new CardTokenRequest(card, tokenDetails -> {
                        Gson gson = new Gson();
                        pendingResult.success(gson.toJson(tokenDetails));

                        return Unit.INSTANCE;
                    }, error -> {
                        pendingResult.error(GENERATE_TOKEN_ERROR, error, null);

                        return Unit.INSTANCE;
                    });

                    mCheckoutAPIClient.createToken(cardTokenisationRequest);
                } catch (Exception ex) {
                    // Return error.
                    result.error(GENERATE_TOKEN_ERROR, ex.getMessage(), ex.getLocalizedMessage());
                }
                break;
            case METHOD_GENERATE_GOOGLE_PAY_TOKEN:
                try {
                    // Set pendingResult to result to use it in callbacks.
                    final Result pendingResult = result;;

                    // Get the args from Flutter.
                    String tokenJsonPayload = call.argument("tokenJsonPayload");

                    // Generate the token.
                    GooglePayTokenRequest googlePayTokenRequest = new GooglePayTokenRequest(tokenJsonPayload, tokenDetails -> {
                        Gson gson = new Gson();
                        pendingResult.success(gson.toJson(tokenDetails));

                        return Unit.INSTANCE;
                    }, error -> {
                        pendingResult.error(GENERATE_TOKEN_ERROR, error, null);

                        return Unit.INSTANCE;
                    });

                    mCheckoutAPIClient.createToken(googlePayTokenRequest);
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
                    ValidationResult cardValidResult = CardValidatorFactory.create().validateCardNumber(cardNumber);

                    // Return the boolean result.
                    result.success(cardValidResult instanceof ValidationResult.Success);
                } catch (Exception ex) {
                    // Return an error.
                    result.error(IS_CARD_VALID_ERROR, ex.getMessage(), ex.getLocalizedMessage());
                }
                break;
            case METHOD_HANDLE_3DS:
                try {
                    // Set pendingResult to result to use it in callbacks.
                    final Result pendingResult = result;

                    // Get the args from Flutter.
                    String authUrl = call.argument("authUrl");
                    String failUrl = call.argument("failUrl");
                    String successUrl = call.argument("successUrl");

                    FrameLayout rootLayout = activity.findViewById(android.R.id.content);
                    ThreeDSRequest threeDSRequest = new ThreeDSRequest(rootLayout, authUrl, successUrl, failUrl,  threeDSResult -> {
                        if (pendingResult == null) {
                            // don't ask me why, but somehow this result handler is sometimes called multiple times
                            // let's ignore it to avoid "Reply already submitted"
                            return null;
                        }

                        if (threeDSResult instanceof ThreeDSResult.Success) {
                            /* Handle success result */
                            String token = ((ThreeDSResult.Success) threeDSResult).getToken();
                            pendingResult.success(token);
                            rootLayout.removeViewAt(rootLayout.getChildCount() - 1);
                        } else if (threeDSResult instanceof ThreeDSResult.Error) {
                            /* Handle error result */
                            String errorMessage = ((ThreeDSResult.Error) threeDSResult).getError().getMessage();
                            pendingResult.error(HANDLE_3DS_ERROR, errorMessage, null);
                            rootLayout.removeViewAt(rootLayout.getChildCount() - 1);
                        } else {
                            /* Handle failure result */
                            pendingResult.error(HANDLE_3DS_ERROR, null, null);
                            rootLayout.removeViewAt(rootLayout.getChildCount() - 1);
                        }
                        return null;
                    });
                    mCheckoutAPIClient.handleThreeDS(threeDSRequest);
                } catch (Exception ex) {
                    result.error(HANDLE_3DS_ERROR, ex.getMessage(), ex.getLocalizedMessage());
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
}
