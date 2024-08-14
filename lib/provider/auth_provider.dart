import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:todo/core/storage_helper.dart';
import 'package:todo/model/auth_model.dart';
import 'package:todo/service/auth_service.dart';

class CustomAuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  bool isLoggedIn = false;
  String? _verificationId;
  String _phoneNumber = '';
  Color _buttonColor = Colors.grey;

  String? get verificationId => _verificationId;
  String get phoneNumber => _phoneNumber;
  Color get buttonColor => _buttonColor;

  // Phone number update logic
  void updatePhoneNumber(String value) {
    _phoneNumber = value;
    _buttonColor =
    _phoneNumber.length == 10 ? Colors.orangeAccent : Colors.grey;
    notifyListeners();
  }

  Future createAccount(AuthModel userModel) async {
    try {
      isError = false;
      isLoading = true;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.createAccount(userModel);
      isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      isError = true;
      isLoading = false;
      notifyListeners();
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: 'The account already exists for that email.');
      } else {
        Fluttertoast.showToast(msg: 'Auth Error ${e.code}');
      }
    } catch (e) {
      isLoading = false;
      isError = true;
      notifyListeners();
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future login(AuthModel userModel) async {
    try {
      isError = false;
      isLoading = true;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.login(userModel);
      StorageHelper storageHelper = Get.find();
      storageHelper.saveLoginStatus();
      isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      isError = true;
      isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
      } else {
        Fluttertoast.showToast(msg: 'Auth Error ${e.code}');
      }
    }
  }

  Future logout() async {
    try {
      isError = false;
      isLoading = false;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.logout();
      StorageHelper storageHelper = Get.find();
      storageHelper.removeLoginStatus();
    } catch (e) {
      isError = true;
      isLoading = false;
      notifyListeners();
    }
  }

  Future resetPassword(String email) async {
    try {
      isError = false;
      isLoading = true;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.resetPassword(email);
      isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Password reset link sent.');
    } on FirebaseAuthException catch (e) {
      isError = true;
      isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Auth Error ${e.code}');
    } catch (e) {
      isLoading = false;
      isError = true;
      notifyListeners();
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future googleLogin() async {
    try {
      isError = false;
      isLoading = true;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.googleLogin();
      StorageHelper storageHelper = Get.find();
      storageHelper.saveLoginStatus();
      isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Google sign in successful');
    } catch (e) {
      isError = true;
      isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Google sign in failed: $e');
    }
  }

  Future verifyPhoneNumber(String phoneNumber) async {
    try {
      isLoading = true;
      isError = false;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.verifyPhoneNumber(phoneNumber, (verificationId) {
        _verificationId = verificationId;
        isLoading = false;
        notifyListeners();
      }, (error) {
        isLoading = false;
        isError = true;
        notifyListeners();
        Fluttertoast.showToast(msg: 'Phone Auth Error: ${error.message}');
      });
    } catch (e) {
      isLoading = false;
      isError = true;
      notifyListeners();
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future signInWithOtp(String verificationId, String otp) async {
    try {
      isLoading = true;
      isError = false;
      notifyListeners();
      AuthService authService = Get.find();
      await authService.signInWithOtp(verificationId, otp);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      isError = true;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Invalid OTP');
    }
  }

  Future loadLoginStatus() async {
    StorageHelper storageHelper = Get.find();
    isLoggedIn = await storageHelper.getLoginStatus();
    notifyListeners();
  }

  void signUp(BuildContext context, String email, String password,
      String confirmPassword) {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
    } else {
      createAccount(AuthModel(email: email, password: password));
    }
  }
}
