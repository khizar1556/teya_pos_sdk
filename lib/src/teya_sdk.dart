import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'models/teya_config.dart';
import 'models/teya_error.dart';
import 'models/payment_state.dart';
import 'models/payment_result.dart';

/// Main class for interacting with the Teya SDK
class TeyaSdk {
  static const MethodChannel _channel = MethodChannel('teya_pos_sdk');
  static const EventChannel _paymentStateChannel = EventChannel('teya_pos_sdk/payment_state');
  
  static TeyaSdk? _instance;
  static TeyaSdk get instance => _instance ??= TeyaSdk._();
  
  TeyaSdk._();

  bool _isInitialized = false;
  StreamSubscription<dynamic>? _paymentStateSubscription;

  /// Initialize the Teya SDK with configuration
  Future<void> initialize(TeyaConfig config) async {
    if (_isInitialized) {
      throw TeyaError(
        code: TeyaErrorCodes.invalidConfiguration,
        message: 'SDK is already initialized',
      );
    }

    // Check platform support
    if (Platform.isIOS) {
      throw TeyaError(
        code: TeyaErrorCodes.platformNotSupported,
        message: 'iOS platform is not supported by Teya SDK. Please use Android for payment processing.',
        details: {
          'platform': 'iOS',
          'supported_platforms': ['Android'],
          'reason': 'Teya SDK does not provide iOS support yet'
        },
      );
    }

    try {
      await _channel.invokeMethod('initialize', config.toMap());
      _isInitialized = true;
    } on PlatformException catch (e) {
      throw TeyaError.fromMap(Map<String, dynamic>.from(e.details ?? {}));
    }
  }

  /// Setup PosLink integration
  Future<void> setupPosLink() async {
    _ensureInitialized();
    
    try {
      await _channel.invokeMethod('setupPosLink');
    } on PlatformException catch (e) {
      throw TeyaError.fromMap(Map<String, dynamic>.from(e.details ?? {}));
    }
  }

  /// Make a payment
  /// 
  /// [amount] - Amount in the smallest currency unit (e.g., cents for GBP)
  /// [currency] - ISO 4217 currency code (e.g., "GBP", "EUR")
  /// [transactionId] - Unique transaction identifier (optional, will be generated if not provided)
  /// [tip] - Optional tip amount in the smallest currency unit
  Future<PaymentResult> makePayment({
    required int amount,
    required String currency,
    String? transactionId,
    int? tip,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _channel.invokeMethod('makePayment', {
        'amount': amount,
        'currency': currency,
        'transactionId': transactionId,
        'tip': tip,
      });
      
      return PaymentResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw TeyaError.fromMap(Map<String, dynamic>.from(e.details ?? {}));
    }
  }

  /// Make a payment with amount in major currency units (e.g., pounds, euros)
  /// 
  /// [amount] - Amount in major currency units (e.g., 5.50 for £5.50)
  /// [currency] - ISO 4217 currency code (e.g., "GBP", "EUR")
  /// [transactionId] - Unique transaction identifier (optional, will be generated if not provided)
  /// [tip] - Optional tip amount in major currency units
  Future<PaymentResult> makePaymentWithMajorUnits({
    required double amount,
    required String currency,
    String? transactionId,
    double? tip,
  }) async {
    final amountInMinorUnits = (amount * 100).round();
    final tipInMinorUnits = tip != null ? (tip * 100).round() : null;
    
    return makePayment(
      amount: amountInMinorUnits,
      currency: currency,
      transactionId: transactionId,
      tip: tipInMinorUnits,
    );
  }

  /// Subscribe to payment state changes
  Stream<PaymentStateDetails> get paymentStateStream {
    _ensureInitialized();
    return _paymentStateChannel
        .receiveBroadcastStream()
        .map((event) {
      try {
        return PaymentStateDetails.fromMap(Map<String, dynamic>.from(event));
      } catch (e, s) {
        debugPrint("Error parsing PaymentStateDetails: $e\n$s");
        // You can decide what to return on error
        return PaymentStateDetails.fromMap({});
      }
    });
  }

/// Cancel the current payment
  Future<bool> cancelPayment() async {
    _ensureInitialized();
    
    try {
      final result = await _channel.invokeMethod('cancelPayment');
      return result == true;
    } on PlatformException catch (e) {
      throw TeyaError.fromMap(Map<String, dynamic>.from(e.details ?? {}));
    }
  }

  /// Check if the SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Check if the SDK is ready for UI operations
  Future<Map<String, dynamic>> isReadyForUI() async {
    _ensureInitialized();
    
    try {
      final result = await _channel.invokeMethod('isReadyForUI');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw TeyaError.fromMap(Map<String, dynamic>.from(e.details ?? {}));
    }
  }

  /// Dispose the SDK and clean up resources
  Future<void> dispose() async {
    await _paymentStateSubscription?.cancel();
    _paymentStateSubscription = null;
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw TeyaError(
        code: TeyaErrorCodes.invalidConfiguration,
        message: 'SDK is not initialized. Call initialize() first.',
      );
    }
  }
}

/// Extension methods for easier usage
extension TeyaSdkExtensions on TeyaSdk {
  /// Make a payment in GBP with amount in pounds
  Future<PaymentResult> makePaymentGBP({
    required double amountInPounds,
    String? transactionId,
    double? tipInPounds,
  }) {
    return makePaymentWithMajorUnits(
      amount: amountInPounds,
      currency: 'GBP',
      transactionId: transactionId,
      tip: tipInPounds,
    );
  }

  /// Make a payment in EUR with amount in euros
  Future<PaymentResult> makePaymentEUR({
    required double amountInEuros,
    String? transactionId,
    double? tipInEuros,
  }) {
    return makePaymentWithMajorUnits(
      amount: amountInEuros,
      currency: 'EUR',
      transactionId: transactionId,
      tip: tipInEuros,
    );
  }

  /// Make a payment in USD with amount in dollars
  Future<PaymentResult> makePaymentUSD({
    required double amountInDollars,
    String? transactionId,
    double? tipInDollars,
  }) {
    return makePaymentWithMajorUnits(
      amount: amountInDollars,
      currency: 'USD',
      transactionId: transactionId,
      tip: tipInDollars,
    );
  }
}
