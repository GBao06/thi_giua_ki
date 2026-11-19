class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String? gender;
  final String? phone;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    this.gender,
    this.phone,
  });

  String get fullName => '$firstName $lastName';

  // Dùng chung cho cả /auth/login và /auth/me (2 API này trả về các field trùng tên)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      image: json['image'] as String? ?? '',
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
