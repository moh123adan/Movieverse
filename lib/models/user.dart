class UserModel {
  final String? id;
  final String? name;
  final String? username;
  final String? email;
  final String? bio;
  final String? photoUrl;
  final String? gender;

  UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.bio,
    this.photoUrl,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'gender': gender,
    };
  }
}
