class User {
  final int id;
  final String username;
  final String email;
  final String mobileNumber;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.mobileNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
    );
  }
}