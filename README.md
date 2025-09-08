# Teya PosLink SDK

[![pub package](https://img.shields.io/pub/v/teya_pos_sdk.svg)](https://pub.dartlang.org/packages/teya_pos_sdk)

A Flutter plugin that provides access to the Teya PosLink SDK for Android. This plugin allows you to integrate Teya payment terminals into your Flutter applications.

**Author**: [Khizar Rehman](https://khizarrehman.com/)

> **⚠️ Platform Support Notice**: This plugin currently supports **Android only**. iOS support is not available as the Teya SDK does not provide iOS support yet.

## Features

- ✅ Initialize Teya SDK with configuration
- ✅ Setup PosLink integration
- ✅ Process card payments
- ✅ Real-time payment state updates
- ✅ Cancel payments
- ✅ Support for multiple currencies (GBP, EUR, USD)
- ✅ Android support
- ❌ iOS support (not available - Teya SDK limitation)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  teya_pos_sdk: ^1.0.1
```

## Setup

### Android Setup

1. **Minimum SDK Version**

   Ensure your `android/app/build.gradle` has a minimum SDK version of 24:

   ```gradle
   android {
       defaultConfig {
           minSdkVersion 24
       }
   }
   ```

2. **Permissions**

   Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

## Usage

### 1. Initialize the SDK

```dart
import 'package:teya_pos_sdk/teya_pos_sdk.dart';

final teyaSdk = TeyaSdk.instance;

// Initialize with sandbox configuration
final config = TeyaConfig.sandbox(
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret',
);

await teyaSdk.initialize(config);

// Check if SDK is ready for UI operations
final uiStatus = await teyaSdk.isReadyForUI();
if (uiStatus['isReady']) {
  await teyaSdk.setupPosLink();
} else {
  print('SDK not ready for UI operations');
}
```

### 2. Make a Payment

```dart
// Make a payment in GBP
final result = await teyaSdk.makePaymentGBP(
  amountInPounds: 5.50,
);

if (result.isSuccess) {
  print('Payment successful! Transaction ID: ${result.transactionId}');
} else {
  print('Payment failed: ${result.errorMessage}');
}
```

### 3. Listen to Payment State Changes

```dart
teyaSdk.paymentStateStream.listen((state) {
  print('Payment state: ${state.state}');
  print('Is final: ${state.isFinal}');
  
  if (state.isFinal) {
    switch (state.state) {
      case PaymentState.successful:
        // Handle successful payment
        break;
      case PaymentState.cancelled:
        // Handle cancelled payment
        break;
      case PaymentState.processingFailed:
        // Handle failed payment
        break;
    }
  }
});
```

### 4. Check UI Readiness

```dart
// Check if the SDK is ready for UI operations before setup
final uiStatus = await teyaSdk.isReadyForUI();
if (uiStatus['isReady']) {
  await teyaSdk.setupPosLink();
} else {
  print('SDK not ready for UI operations');
  print('Has activity: ${uiStatus['hasActivity']}');
  print('Has SDK: ${uiStatus['hasSDK']}');
}
```

### 5. Cancel a Payment

```dart
final cancelled = await teyaSdk.cancelPayment();
if (cancelled) {
  print('Payment cancelled successfully');
}
```

## API Reference

### TeyaSdk

The main class for interacting with the Teya SDK.

#### Methods

- `initialize(TeyaConfig config)` - Initialize the SDK
- `setupPosLink()` - Setup PosLink integration
- `makePayment({required int amount, required String currency, String? transactionId, int? tip})` - Make a payment
- `makePaymentWithMajorUnits({required double amount, required String currency, String? transactionId, double? tip})` - Make a payment with amount in major currency units
- `makePaymentGBP({required double amountInPounds, String? transactionId, double? tipInPounds})` - Make a payment in GBP
- `makePaymentEUR({required double amountInEuros, String? transactionId, double? tipInEuros})` - Make a payment in EUR
- `makePaymentUSD({required double amountInDollars, String? transactionId, double? tipInDollars})` - Make a payment in USD
- `cancelPayment()` - Cancel the current payment
- `isReadyForUI()` - Check if the SDK is ready for UI operations
- `dispose()` - Dispose the SDK and clean up resources

#### Properties

- `paymentStateStream` - Stream of payment state changes
- `isInitialized` - Whether the SDK is initialized

### TeyaConfig

Configuration for the Teya SDK.

#### Constructors

- `TeyaConfig({required String teyaIdHostUrl, required String teyaApiHostUrl, required String clientId, required String clientSecret, bool isProduction = false})`
- `TeyaConfig.sandbox({required String clientId, required String clientSecret})`
- `TeyaConfig.production({required String clientId, required String clientSecret})`

### PaymentState

Enum representing payment states:

- `new_` - Payment is new
- `inProgress` - Payment is in progress
- `pending` - Payment is pending
- `successful` - Payment was successful
- `cancelled` - Payment was cancelled
- `cancelling` - Payment is being cancelled
- `processingFailed` - Payment processing failed
- `communicationFailed` - Communication with terminal failed

### PaymentResult

Result of a payment operation.

#### Properties

- `isSuccess` - Whether the payment was successful
- `transactionId` - Transaction ID
- `eposTransactionId` - ePOS transaction ID
- `finalState` - Final payment state
- `errorMessage` - Error message if payment failed
- `metadata` - Additional metadata

## Error Handling

The plugin throws `TeyaError` exceptions for various error conditions:

```dart
try {
  await teyaSdk.makePaymentGBP(amountInPounds: 10.0);
} on TeyaError catch (e) {
  print('Teya error: ${e.code} - ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Troubleshooting

### Common Issues

#### 1. SDK Navigation Not Working

If the Teya setup UI opens but navigation doesn't work when clicking buttons:

**Solution**: Ensure the SDK is ready for UI operations before calling `setupPosLink()`:

```dart
// Check UI readiness first
final uiStatus = await teyaSdk.isReadyForUI();
if (!uiStatus['isReady']) {
  print('SDK not ready for UI operations');
  return;
}

await teyaSdk.setupPosLink();
```

#### 2. Activity Context Not Available

If you get "Activity context is not available" error:

**Solution**: Make sure you're calling the SDK methods from a Flutter widget that has an active Android activity context. The SDK needs an activity context to display UI.

#### 3. Setup Failed Errors

If `setupPosLink()` fails:

**Solution**: Check the Android logs for detailed error information:

```bash
flutter logs
```

Look for logs with the "TeyaSDK" tag for detailed debugging information.

#### 4. Platform Not Supported on iOS

If you get platform not supported errors on iOS:

**Solution**: This plugin only supports Android. The Teya SDK does not provide iOS support yet.

## Example

See the `example/` directory inside this plugin for a complete example application demonstrating how to use the plugin.

To run the example:
```bash
cd example
flutter pub get
flutter run
```

## Requirements

- Flutter 3.10.0 or higher
- Dart 3.0.0 or higher
- **Android API level 24 or higher** (iOS not supported)
- Teya SDK (included in the plugin)

## Platform Support

| Platform | Support Status | Notes |
|----------|---------------|-------|
| Android | ✅ Supported | Full functionality available |
| iOS | ❌ Not Supported | Teya SDK does not provide iOS support |

### iOS Compatibility

If you try to use this plugin on iOS, you will receive a clear error message:

```dart
try {
  await teyaSdk.initialize(config);
} on TeyaError catch (e) {
  if (e.code == TeyaErrorCodes.platformNotSupported) {
    print('iOS is not supported: ${e.message}');
    // Handle iOS not supported case
  }
}
```

## License

This plugin is provided as-is. Please refer to Teya's licensing terms for the underlying SDK.

## Support

For issues related to this Flutter plugin, please create an issue in the repository. For Teya SDK specific issues, please contact Teya support.
