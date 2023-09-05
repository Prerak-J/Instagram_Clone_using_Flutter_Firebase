import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class PostModel {
  final String username;
  final String description;
  final String postId;
  final DateTime datePublished;
  final String uid;
  final String postURL;
  final String profImage;
  final List likes;

  const PostModel({
    required this.username,
    required this.description,
    required this.postId,
    required this.uid,
    required this.datePublished,
    required this.postURL,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'description': description,
        'postId': postId,
        'uid': uid,
        'datePublished': datePublished,
        'postURL': postURL,
        'profImage': profImage,
        'likes': likes,
      };

  static PostModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PostModel(
      username: snap['username'],
      description: snap['description'],
      postId: snap['postId'],
      datePublished: snap['datePublished'],
      uid: snap['uid'],
      postURL: snap['postURL'],
      profImage: snap['profImage'],
      likes: snap['likes'],
    );
  }
}
