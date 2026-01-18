class User {
  final int id;
  final String name;
  final String email;
  final String provider;
  final bool isPremium;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.isPremium,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawPremium = json['isPremium'];

    bool premium;
    if (rawPremium is bool) {
      premium = rawPremium;
    } else if (rawPremium is num) {
      premium = rawPremium == 1;
    } else if (rawPremium is String) {
      premium =
          rawPremium == '1' || rawPremium.toLowerCase() == 'true';
    } else {
      premium = false;
    }

    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? 'local',
      isPremium: premium,
    );
  }
}
