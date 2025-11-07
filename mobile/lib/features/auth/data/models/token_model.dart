import 'package:equatable/equatable.dart';

class TokenModel extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final String? scope;
  final String? idToken;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const TokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.scope,
    this.idToken,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final issuedAt = DateTime.now();
    final expiresIn = json['expires_in'] as int? ?? 3600;
    
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: expiresIn,
      scope: json['scope'] as String?,
      idToken: json['id_token'] as String?,
      issuedAt: issuedAt,
      expiresAt: issuedAt.add(Duration(seconds: expiresIn)),
    );
  }

  factory TokenModel.fromAzureResponse(Map<String, dynamic> json) {
    final issuedAt = DateTime.now();
    final expiresIn = json['expires_in'] as int? ?? 3600;
    
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: expiresIn,
      scope: json['scope'] as String?,
      idToken: json['id_token'] as String?,
      issuedAt: issuedAt,
      expiresAt: issuedAt.add(Duration(seconds: expiresIn)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'scope': scope,
      'id_token': idToken,
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Check if the access token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if the access token will expire soon (within 5 minutes)
  bool get isExpiringSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Get remaining time until expiration
  Duration get timeUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Get the authorization header value
  String get authorizationHeader => '$tokenType $accessToken';

  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    String? scope,
    String? idToken,
    DateTime? issuedAt,
    DateTime? expiresAt,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      scope: scope ?? this.scope,
      idToken: idToken ?? this.idToken,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        tokenType,
        expiresIn,
        scope,
        idToken,
        issuedAt,
        expiresAt,
      ];

  @override
  String toString() {
    return 'TokenModel{tokenType: $tokenType, expiresIn: $expiresIn, isExpired: $isExpired}';
  }
}