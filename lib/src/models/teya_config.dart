/// Configuration for Teya SDK initialization
class TeyaConfig {
  /// Teya ID host URL (e.g., "id.teya.xyz" for sandbox, "id.teya.com" for production)
  final String teyaIdHostUrl;
  
  /// Teya API host URL (e.g., "api.teya.xyz" for sandbox, "api.teya.com" for production)
  final String teyaApiHostUrl;
  
  /// Client ID obtained from Teya developer portal
  final String clientId;
  
  /// Client secret obtained from Teya developer portal
  final String clientSecret;
  
  /// Whether to use production environment (default: false for sandbox)
  final bool isProduction;

  const TeyaConfig({
    required this.teyaIdHostUrl,
    required this.teyaApiHostUrl,
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
      teyaIdHostUrl: "id.teya.xyz",
      teyaApiHostUrl: "api.teya.xyz",
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
      teyaIdHostUrl: "id.teya.com",
      teyaApiHostUrl: "api.teya.com",
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
      teyaIdHostUrl: map['teyaIdHostUrl'] ?? '',
      teyaApiHostUrl: map['teyaApiHostUrl'] ?? '',
      clientId: map['clientId'] ?? '',
      clientSecret: map['clientSecret'] ?? '',
      isProduction: map['isProduction'] ?? false,
    );
  }
}
