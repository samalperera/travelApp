class AppUser {
  final String id;
  final String email;
  final String userName;

  AppUser({
    required this.id,
    required this.email,
    required this.userName,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      userName: data['userName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'userName': userName,
    };
  }
}
