class UserModel {
  final String name;
  final String email;
  final String? bio;

  UserModel({required this.name, required this.email,this.bio});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
    };
  }
}
