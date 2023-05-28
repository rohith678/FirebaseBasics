class UserModal {
  final String name;
  final String email;
  final String bio;
  String profilePic;
  String phoneNumber;
  String createdAt;
  String uid;

  UserModal(
      {required this.name,
      required this.email,
      required this.bio,
      required this.profilePic,
      required this.phoneNumber,
      required this.createdAt,
      required this.uid});

  //from map
  factory UserModal.fromMap(Map<String, dynamic> map) {
    return UserModal(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        bio: map['bio'] ?? '',
        profilePic: map['profilePic'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        createdAt: map['createdAt'] ?? '',
        uid: map['uid'] ?? '');
  }

  //to map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "uid": uid,
      "bio": bio,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt
    };
  }
}
