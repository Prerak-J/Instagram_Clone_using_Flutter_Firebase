import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    String postId = const Uuid().v1();

    try {
      String photoURL = await StorageMethods().uploadImageToStorage('posts', file, true);
      PostModel postModel = PostModel(
        username: username,
        description: description,
        postId: postId,
        uid: uid,
        datePublished: DateTime.now(),
        postURL: photoURL,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(postModel.toJson());
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      // print(e.toString());
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String username,
    String profPic,
  ) async {
    String res = "Some error occured";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': profPic,
          'username': username,
          'commentText': text,
          'commentId': commentId,
          'uid': uid,
          'datePublished': DateTime.now(),
        });
        res = "Comment posted!";
      } else {
        // showSnackBar('Text is empty', context);
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> deletePost(String postId) async {
    try {
      _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      // print(e.toString());
    }
  }

  Future<void> followUser(
    String uid,
    String followId,
  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = snap['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          "followers": FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          "following": FieldValue.arrayRemove([followId])
        });
      } else{
        await _firestore.collection('users').doc(followId).update({
          "followers": FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          "following": FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      //
    }
  }
}
