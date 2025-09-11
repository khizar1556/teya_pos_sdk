/// Configuration for Teya SDK initialization
class TeyaConfig {
  /// Client ID obtained from Teya developer portal
  final String clientId;

  /// Client secret obtained from Teya developer portal
  final String clientSecret;

  /// Whether to use production environment (default: false for sandbox)
  final bool isProduction;

  const TeyaConfig({
    required this.clientId,
    required this.clientSecret,
    this.isProduction = false,
  });

  /// Create a sandbox configuration
  factory TeyaConfig.sandbox({
    required String clientId,
    required String clientSecret,
  }) {
    return TeyaConfig(
      clientId: clientId,
      clientSecret: clientSecret,
      isProduction: false,
    );
  }

  /// Create a production configuration
  factory TeyaConfig.production({
    required String clientId,
    required String clientSecret,
  }) {
    return TeyaConfig(
      clientId: clientId,
      clientSecret: clientSecret,
      isProduction: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'isProductionEnv': isProduction,
    };
  }

  factory TeyaConfig.fromMap(Map<String, dynamic> map) {
    return TeyaConfig(
      clientId: map['clientId'] ?? '',
      clientSecret: map['clientSecret'] ?? '',
      isProduction: map['isProduction'] ?? false,
    );
  }
}
