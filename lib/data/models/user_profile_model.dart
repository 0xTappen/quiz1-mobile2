class UserProfileModel {
  final String name;
  final String email;
  final String occupation;
  final String? avatarUrl;

  const UserProfileModel({
    required this.name,
    required this.email,
    required this.occupation,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'occupation': occupation,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? occupation,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
