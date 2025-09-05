# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

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
