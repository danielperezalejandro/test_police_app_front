class User {
  final int id;
  final String name;
  final String email;
  final String provider;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      provider: json['provider'] ?? 'local',
    );
  }
}
