class UserModel {
  final int id;
  final String firebaseUid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String role;
  final bool active;
  final String? bio;
  final String? address;
  final DateTime createdAt;

  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    required this.active,
    this.bio,
    this.address,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        firebaseUid: j['firebaseUid'] ?? '',
        name: j['name'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        profileImageUrl: j['profileImageUrl'],
        role: j['role'] ?? 'USER',
        active: j['active'] ?? true,
        bio: j['bio'],
        address: j['address'],
        createdAt: _parseDate(j['createdAt']),
      );

  /// Handles both "yyyy-MM-dd HH:mm:ss" (backend custom format)
  /// and standard ISO "yyyy-MM-ddTHH:mm:ss".
  /// DateTime.parse() requires the 'T' separator — we insert it if missing.
  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    final s = raw.toString();
    // "2024-02-19 12:40:00" → "2024-02-19T12:40:00"
    return DateTime.parse(s.replaceFirst(' ', 'T'));
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    String? address,
  }) =>
      UserModel(
        id: id,
        firebaseUid: firebaseUid,
        name: name ?? this.name,
        email: email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        role: role,
        active: active,
        bio: bio ?? this.bio,
        address: address ?? this.address,
        createdAt: createdAt,
      );
}
