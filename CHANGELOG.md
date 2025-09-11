# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5]

### Added
- Enhanced payment result handling with structured metadata
- Gateway Payment ID support in payment results
- Proper Metadata model integration for payment results

### Changed
- Updated PaymentResult to use GatewayPaymentId object instead of String
- Updated PaymentResult to use structured Metadata model instead of Map<String, dynamic>
- Enhanced Android plugin serialization to use consistent state.toMap() approach
- Improved payment state display to show Gateway Payment ID in real-time
- Updated example app to prioritize Gateway Payment ID over Transaction ID

### Fixed
- Fixed Android plugin serialization issues that caused crashes
- Improved data consistency between payment state stream and payment results
- Enhanced type safety for metadata access in payment results

## [1.0.4]

### Changed
- Misc
- Enhanced package description and metadata

## [1.0.3]

### Security
- Remove hardcoded client credentials from example app
- Add placeholder text to guide users to enter their own credentials
- Improve security by not exposing credentials in example code

## [1.0.2]

### Removed
- `cancelPayment()` method from Dart SDK
- Cancel payment functionality from Android implementation
- Cancel payment button from example app UI
- Cancel payment documentation from README

### Changed
- Simplified payment flow to focus on payment initiation and completion
- Updated example app UI to remove cancel button and related functionality

## [1.0.1]

### Added
- Repository and issue tracker links to pub.dev package page
- Pub package badge in README
- Explicit publish destination configuration

### Fixed
- Dart formatting issues in payment model files
- Unused import in payment_state.dart

### Changed
- Updated package name from `teya_poslink_sdk` to `teya_pos_sdk`
- Updated Android package structure to `com.khizar1556.teya_pos_sdk`
- Removed hardcoded client credentials from example app
- Updated all documentation and examples to use new package name

### Security
- Removed static client ID and secret from example application
- Users now must provide their own credentials through UI

## [1.0.0]

### Added
- Initial release of Flutter Teya SDK plugin
- Android platform support
- SDK initialization with configuration
- PosLink integration setup
- Card payment processing
- Real-time payment state updates
- Payment cancellation support
- Support for multiple currencies (GBP, EUR, USD)
- Comprehensive error handling
- Example Flutter application
- Complete documentation

### Features
- `TeyaSdk` - Main SDK class for payment operations
- `TeyaConfig` - Configuration management for sandbox and production environments
- `PaymentState` - Enum for payment states with real-time updates
- `PaymentResult` - Result handling for payment operations
- `TeyaError` - Comprehensive error handling with specific error codes
- Extension methods for easy currency-specific payments

### Android Implementation
- Native Android bridge using MethodChannel and EventChannel
- Integration with Teya Unified ePOS SDK
- Proper lifecycle management
- Error handling and state management

### iOS Implementation
- Clear platform not supported errors with detailed messages
- iOS support blocked at Dart level for better user experience
- Ready for future iOS SDK integration when Teya provides iOS support

### Documentation
- Complete README with setup instructions
- API reference documentation
- Usage examples
- Error handling guide
