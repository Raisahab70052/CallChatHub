class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.status,
    required this.isOnline,
    this.email = '',
    this.fcmToken,
    this.avatarUrl,
    this.unread = 0,
  });

  final String id;
  final String name;
  final String email;
  final String? fcmToken;
  final String status;
  final bool isOnline;
  final String? avatarUrl;
  final int unread;

  String get initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      fcmToken: json['fcmToken'] as String?,
      status: json['status'] as String,
      isOnline: json['isOnline'] as bool,
      avatarUrl: json['avatarUrl'] as String?,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a UserModel from a Firestore document map.
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    final bool online = data['isOnline'] as bool? ?? false;
    return UserModel(
      id: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      fcmToken: data['fcmToken'] as String?,
      status: online ? 'online' : 'offline',
      isOnline: online,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'fcmToken': fcmToken,
      'status': status,
      'isOnline': isOnline,
      'avatarUrl': avatarUrl,
      'unread': unread,
    };
  }
}
