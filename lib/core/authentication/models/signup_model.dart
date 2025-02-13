class SignupModel {
  final String id;
  final String name;
  final String email;
  final String password;
  // final String imageUrl;
  // final String bio;

  SignupModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    // required this.imageUrl,
    // required this.bio,
  });

  // Convert SignupModel to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      // 'imageUrl': imageUrl,
      // 'bio': bio,
    };
  }

  // Factory constructor to create instance from Firestore
  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      // imageUrl: json['imageUrl'] ?? '',
      // bio: json['bio'] ?? '',
    );
  }
}
