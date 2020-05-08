#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_checkout_payment.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_checkout_payment'
  s.version          = '0.0.1'
  s.summary          = 'This Flutter plugin is for Checkout.com online payment.'
  s.description      = <<-DESC
This Flutter plugin is for Checkout.com online payment.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'shady_alkrar@yahoo.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Frames', '~> 3.0'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
