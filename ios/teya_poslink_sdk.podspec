#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_teya_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'teya_poslink_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Teya Unified ePOS SDK (Android only)'
  s.description      = <<-DESC
Flutter plugin for Teya Unified ePOS SDK. Currently supports Android only.
iOS support is not available as Teya SDK does not support iOS platform yet.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
