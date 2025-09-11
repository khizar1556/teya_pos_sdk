/// Represents an error from the Teya SDK
class TeyaError {
  /// Error code
  final String code;

  /// Error message
  final String message;

  /// Additional error details
  final Map<String, dynamic>? details;

  const TeyaError({
    required this.code,
    required this.message,
    this.details,
  });

  factory TeyaError.fromMap(Map<String, dynamic> map) {
    return TeyaError(
      code: map['code'] ?? 'UNKNOWN_ERROR',
      message: map['message'] ?? 'An unknown error occurred',
      details: map['details'] != null
          ? Map<String, dynamic>.from(map['details'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'details': details,
    };
  }

  @override
  String toString() {
    return 'TeyaError(code: $code, message: $message, details: $details)';
  }
}

/// Common error codes
class TeyaErrorCodes {
  static const String setupFailed = 'SETUP_FAILED';
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String paymentCancelled = 'PAYMENT_CANCELLED';
  static const String networkError = 'NETWORK_ERROR';
  static const String authenticationFailed = 'AUTHENTICATION_FAILED';
  static const String deviceNotLinked = 'DEVICE_NOT_LINKED';
  static const String invalidConfiguration = 'INVALID_CONFIGURATION';
  static const String platformNotSupported = 'PLATFORM_NOT_SUPPORTED';
  static const String unknownError = 'UNKNOWN_ERROR';
}
