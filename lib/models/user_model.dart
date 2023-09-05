import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String username;
  final String bio;
  final String email;
  final String password;
  final String uid;
  final List followers;
  final List following;
  final String photoURL;

  const UserModel({
    required this.username,
    required this.bio,
    required this.email,
    required this.uid,
    required this.password,
    required this.followers,
    required this.following,
    required this.photoURL,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'bio': bio,
        'email': email,
        'uid': uid,
        'password': password,
        'followers': followers,
        'following': following,
        'photoURL': photoURL,
      };

  static UserModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      username: snap['username'],
      bio: snap['bio'],
      email: snap['email'],
      password: snap['password'],
      uid: snap['uid'],
      followers: snap['followers'],
      following: snap['following'],
      photoURL: snap['photoURL'],
    );
  }
}
