import 'payment_state.dart';

/// Result of a payment operation
class PaymentResult {
  /// Whether the payment was successful
  final bool isSuccess;

  /// Transaction ID
  final String? transactionId;

  /// ePOS transaction ID
  final String? eposTransactionId;

  /// Gateway payment ID for refunds
  final GatewayPaymentId? gatewayPaymentId;

  /// Final payment state
  final PaymentState? finalState;

  /// Error details if payment failed
  final String? errorMessage;

  /// Additional metadata
  final Metadata? metadata;

  const PaymentResult({
    required this.isSuccess,
    this.transactionId,
    this.eposTransactionId,
    this.gatewayPaymentId,
    this.finalState,
    this.errorMessage,
    this.metadata,
  });

  /// Create a successful payment result
  factory PaymentResult.success({
    required String transactionId,
    String? eposTransactionId,
    Metadata? metadata,
  }) {
    return PaymentResult(
      isSuccess: true,
      transactionId: transactionId,
      eposTransactionId: eposTransactionId,
      finalState: PaymentState.successful,
      metadata: metadata,
    );
  }

  /// Create a failed payment result
  factory PaymentResult.failure({
    String? transactionId,
    String? errorMessage,
    PaymentState? finalState,
    Metadata? metadata,
  }) {
    return PaymentResult(
      isSuccess: false,
      transactionId: transactionId,
      finalState: finalState,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      isSuccess: map['isSuccess'] ?? false,
      transactionId: map['transactionId'],
      eposTransactionId: map['eposTransactionId'],
      gatewayPaymentId: map['gatewayPaymentId'] != null
          ? GatewayPaymentId.fromMap(map['gatewayPaymentId'])
          : null,
      finalState: map['state'] != null
          ? _parsePaymentState(map['state'])
          : (map['finalState'] != null
              ? _parsePaymentState(map['finalState'])
              : null),
      errorMessage: map['errorMessage'],
      metadata: map['metadata'] != null
          ? Metadata.fromMap(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'transactionId': transactionId,
      'eposTransactionId': eposTransactionId,
      'gatewayPaymentId': gatewayPaymentId?.toMap(),
      'finalState':
          finalState != null ? _paymentStateToString(finalState!) : null,
      'errorMessage': errorMessage,
      'metadata': metadata?.toMap(),
    };
  }

  @override
  String toString() {
    return 'PaymentResult(isSuccess: $isSuccess, transactionId: $transactionId, eposTransactionId: $eposTransactionId, finalState: $finalState, errorMessage: $errorMessage)';
  }

  static PaymentState _parsePaymentState(String state) {
    switch (state.toLowerCase()) {
      case 'new':
        return PaymentState.new_;
      case 'inprogress':
        return PaymentState.inProgress;
      case 'pending':
        return PaymentState.pending;
      case 'successful':
        return PaymentState.successful;
      case 'cancelled':
      case 'canceled':
        return PaymentState.cancelled;
      case 'cancelling':
        return PaymentState.cancelling;
      case 'processingfailed':
        return PaymentState.processingFailed;
      case 'communicationfailed':
        return PaymentState.communicationFailed;
      default:
        return PaymentState.new_;
    }
  }

  static String _paymentStateToString(PaymentState state) {
    switch (state) {
      case PaymentState.new_:
        return 'new';
      case PaymentState.inProgress:
        return 'inProgress';
      case PaymentState.pending:
        return 'pending';
      case PaymentState.successful:
        return 'successful';
      case PaymentState.cancelled:
        return 'cancelled';
      case PaymentState.cancelling:
        return 'cancelling';
      case PaymentState.processingFailed:
        return 'processingFailed';
      case PaymentState.communicationFailed:
        return 'communicationFailed';
    }
  }
}
