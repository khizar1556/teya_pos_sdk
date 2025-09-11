/// Represents the state of a payment transaction
enum PaymentState {
  /// Payment is new and hasn't started processing
  new_,

  /// Payment is in progress
  inProgress,

  /// Payment is pending
  pending,

  /// Payment was successful
  successful,

  /// Payment was cancelled
  cancelled,

  /// Payment is being cancelled
  cancelling,

  /// Payment processing failed
  processingFailed,

  /// Communication with payment terminal failed
  communicationFailed,
}

/// Represents the reason for a payment state change
enum PaymentStateReason {
  /// Cancelled by the ePOS terminal
  cancelledByEpos,

  /// Cancelled by the user
  cancelledByUser,

  /// Communication failed due to authentication required
  communicationFailedAuthRequired,

  /// Communication failed due to network issues
  communicationFailedNetwork,

  /// Communication failed unexpectedly
  communicationFailedUnexpectedly,

  /// Payment expired
  expired,

  /// Card processing error
  processingFailedCardProcessingError,

  /// Communication timeout
  processingFailedCommTimeout,

  /// Connection error
  processingFailedConnectionError,

  /// Card declined offline
  processingFailedDeclinedOffline,

  /// Card declined online
  processingFailedDeclinedOnline,

  /// Processing timeout
  processingFailedTimeout,

  /// Unknown reason
  unknown,
}

/// Details about a payment state change
class PaymentStateDetails {
  /// Current payment state
  final PaymentState state;

  /// Reason for the state change
  final PaymentStateReason? reason;

  /// Whether this is a final state
  final bool isFinal;

  /// ePOS transaction ID
  final String? eposTransactionId;

  /// Gateway payment ID for refunds
  final GatewayPaymentId? gatewayPaymentId;

  /// Payment amount
  final int? amount;

  /// Tip amount
  final int? tip;

  /// Currency code
  final String? currency;

  /// Additional metadata
  final Metadata? metadata;

  const PaymentStateDetails({
    required this.state,
    this.reason,
    required this.isFinal,
    this.eposTransactionId,
    this.gatewayPaymentId,
    this.amount,
    this.tip,
    this.currency,
    this.metadata,
  });

  factory PaymentStateDetails.fromMap(Map<String, dynamic> map) {
    return PaymentStateDetails(
      state: _parsePaymentState(map['state']),
      reason: map['reason'] != null
          ? _parsePaymentStateReason(map['reason'])
          : null,
      isFinal: map['isFinal'] ?? false,
      eposTransactionId: map['eposTransactionId'],
      gatewayPaymentId: map['gatewayPaymentId'] != null
          ? GatewayPaymentId.fromMap(map['gatewayPaymentId'])
          : null,
      amount: map['amount'],
      tip: map['tip'],
      currency: map['currency'],
      metadata:
          map["metadata"] != null ? Metadata.fromMap(map["metadata"]) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': _paymentStateToString(state),
      'reason': reason != null ? _paymentStateReasonToString(reason!) : null,
      'isFinal': isFinal,
      'eposTransactionId': eposTransactionId,
      'gatewayPaymentId': gatewayPaymentId,
      'amount': amount,
      'tip': tip,
      'currency': currency,
      'metadata': metadata,
    };
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

  static PaymentStateReason _parsePaymentStateReason(String reason) {
    switch (reason.toLowerCase()) {
      case 'cancelledbyepos':
        return PaymentStateReason.cancelledByEpos;
      case 'cancelledbyuser':
        return PaymentStateReason.cancelledByUser;
      case 'communicationfailedauthrequired':
        return PaymentStateReason.communicationFailedAuthRequired;
      case 'communicationfailednetwork':
        return PaymentStateReason.communicationFailedNetwork;
      case 'communicationfailedunexpectedly':
        return PaymentStateReason.communicationFailedUnexpectedly;
      case 'expired':
        return PaymentStateReason.expired;
      case 'processingfailedcardprocessingerror':
        return PaymentStateReason.processingFailedCardProcessingError;
      case 'processingfailedcommtimeout':
        return PaymentStateReason.processingFailedCommTimeout;
      case 'processingfailedconnectionerror':
        return PaymentStateReason.processingFailedConnectionError;
      case 'processingfaileddeclinedoffline':
        return PaymentStateReason.processingFailedDeclinedOffline;
      case 'processingfaileddeclinedonline':
        return PaymentStateReason.processingFailedDeclinedOnline;
      case 'processingfailedtimeout':
        return PaymentStateReason.processingFailedTimeout;
      default:
        return PaymentStateReason.unknown;
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

  static String _paymentStateReasonToString(PaymentStateReason reason) {
    switch (reason) {
      case PaymentStateReason.cancelledByEpos:
        return 'cancelledByEpos';
      case PaymentStateReason.cancelledByUser:
        return 'cancelledByUser';
      case PaymentStateReason.communicationFailedAuthRequired:
        return 'communicationFailedAuthRequired';
      case PaymentStateReason.communicationFailedNetwork:
        return 'communicationFailedNetwork';
      case PaymentStateReason.communicationFailedUnexpectedly:
        return 'communicationFailedUnexpectedly';
      case PaymentStateReason.expired:
        return 'expired';
      case PaymentStateReason.processingFailedCardProcessingError:
        return 'processingFailedCardProcessingError';
      case PaymentStateReason.processingFailedCommTimeout:
        return 'processingFailedCommTimeout';
      case PaymentStateReason.processingFailedConnectionError:
        return 'processingFailedConnectionError';
      case PaymentStateReason.processingFailedDeclinedOffline:
        return 'processingFailedDeclinedOffline';
      case PaymentStateReason.processingFailedDeclinedOnline:
        return 'processingFailedDeclinedOnline';
      case PaymentStateReason.processingFailedTimeout:
        return 'processingFailedTimeout';
      case PaymentStateReason.unknown:
        return 'unknown';
    }
  }

  @override
  String toString() {
    return 'PaymentStateDetails(state: $state, reason: $reason, isFinal: $isFinal, eposTransactionId: $eposTransactionId)';
  }
}

class Metadata {
  final CardModel? card;
  final String entryMode;
  final String verificationMethod;
  final String? applicationId;
  final String merchantAcquiringId;
  final String responseCode;
  final String authorisationCode;

  Metadata({
    this.card,
    required this.entryMode,
    required this.verificationMethod,
    this.applicationId,
    required this.merchantAcquiringId,
    required this.responseCode,
    required this.authorisationCode,
  });

  factory Metadata.fromMap(Map<dynamic, dynamic> map) {
    return Metadata(
      card: map["card"] != null ? CardModel.fromMap(map["card"]) : null,
      entryMode: map["entryMode"],
      verificationMethod: map["verificationMethod"],
      applicationId: map["applicationId"],
      merchantAcquiringId: map["merchantAcquiringId"],
      responseCode: map["responseCode"],
      authorisationCode: map["authorisationCode"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'card': card?.toMap(),
      'entryMode': entryMode,
      'verificationMethod': verificationMethod,
      'applicationId': applicationId,
      'merchantAcquiringId': merchantAcquiringId,
      'responseCode': responseCode,
      'authorisationCode': authorisationCode,
    };
  }
}

class CardModel {
  final String last4;
  final String? issuingCountry;
  final String brand;
  final String? type;

  CardModel({
    required this.last4,
    this.issuingCountry,
    required this.brand,
    this.type,
  });

  factory CardModel.fromMap(Map<dynamic, dynamic> map) {
    return CardModel(
      last4: map["last4"],
      issuingCountry: map["issuingCountry"],
      brand: map["brand"],
      type: map["type"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'last4': last4,
      'issuingCountry': issuingCountry,
      'brand': brand,
      'type': type,
    };
  }
}

class GatewayPaymentId {
  final String? id;

  GatewayPaymentId({
    this.id,
  });

  factory GatewayPaymentId.fromMap(Map<dynamic, dynamic> map) {
    return GatewayPaymentId(
      id: map["id"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }
}
