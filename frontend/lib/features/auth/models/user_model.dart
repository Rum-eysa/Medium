class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id, required this.firebaseUid, required this.email,
    this.displayName, this.photoUrl, this.isActive = true, required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j["id"] as String,
    firebaseUid: j["firebase_uid"] as String,
    email: j["email"] as String,
    displayName: j["display_name"] as String?,
    photoUrl: j["photo_url"] as String?,
    isActive: j["is_active"] as bool? ?? true,
    createdAt: DateTime.parse(j["created_at"] as String),
  );

  UserModel copyWith({String? displayName, String? photoUrl}) => UserModel(
    id: id, firebaseUid: firebaseUid, email: email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    isActive: isActive, createdAt: createdAt,
  );
}