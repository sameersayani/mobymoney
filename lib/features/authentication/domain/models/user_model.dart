class UserModel {
  final int id;
  final String email;
  final String name;
  final String? picture;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
    };
  }
}
