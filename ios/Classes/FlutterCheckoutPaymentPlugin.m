#import "FlutterCheckoutPaymentPlugin.h"
#if __has_include(<flutter_checkout_payment/flutter_checkout_payment-Swift.h>)
#import <flutter_checkout_payment/flutter_checkout_payment-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_checkout_payment-Swift.h"
#endif

@implementation FlutterCheckoutPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCheckoutPaymentPlugin registerWithRegistrar:registrar];
}
@end
