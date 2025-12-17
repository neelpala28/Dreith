class UserModel {
  final String name;
  final String email;
  final String? bio;
  final String? profession;

  UserModel({required this.name, required this.email,this.bio, this.profession});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profession: map['profession'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'profession': profession,
    };
  }
}
