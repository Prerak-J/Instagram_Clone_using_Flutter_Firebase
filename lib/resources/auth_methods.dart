import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User currUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currUser.uid).get();

    return UserModel.fromSnap(snap);
  }

  //sign up user
  Future<String> signUpUser({
    required String username,
    required String bio,
    required String email,
    required String password,
    Uint8List? fileAuth,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // print(cred.user!.uid);

        String photoURL = 'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg';

        if (fileAuth != null) {
          photoURL = await StorageMethods().uploadImageToStorage('profilePics', fileAuth, false);
        }

        UserModel userModel = UserModel(
          username: username,
          bio: bio,
          email: email,
          uid: cred.user!.uid,
          password: password,
          followers: [],
          following: [],
          photoURL: photoURL,
        );

        // add user to db
        await _firestore.collection('users').doc(cred.user!.uid).set(
              userModel.toJson(),
            );

        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  //login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> signOut() async {
    String res = "Some error occured";
    try {
      await _auth.signOut();
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
