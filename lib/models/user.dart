class User {
  final int userId;
  final String userName;
  final String userNameAr;
  final String email;
  final String? phoneNumber;
  final String roles;

  User({
    required this.userId,
    required this.userName,
    required this.userNameAr,
    required this.email,
    this.phoneNumber,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userNameAr: json['userNameAr'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      roles: json['roles'] ?? '',
    );
  }
}