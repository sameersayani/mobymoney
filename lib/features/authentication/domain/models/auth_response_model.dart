import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] is int
          ? json['expires_in'] as int
          : int.tryParse('${json['expires_in']}') ?? 0,
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}
