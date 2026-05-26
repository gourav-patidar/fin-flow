/// The signed-in user. Plain Dart class — hand-written JSON so Phase 3 has
/// no codegen dependency. Will be replaced by Firebase `User` mapping in
/// Phase 12 without changing this surface.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        photoUrl: json['photoUrl'] as String?,
      );

  AppUser copyWith({String? displayName, String? photoUrl}) => AppUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(id, email, displayName, photoUrl);
}
