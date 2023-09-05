import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  final AuthMethods _authMethods = AuthMethods();
  UserModel? _user;

  UserModel get getUser => _user!;

  Future<void> refreshUser() async {
    UserModel userModel = await _authMethods.getUserDetails();
    _user = userModel;
    notifyListeners();
    print('user changed.............');
  }
}
