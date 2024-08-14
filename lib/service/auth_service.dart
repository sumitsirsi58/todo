import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/auth_model.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> createAccount(AuthModel userModel) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );
      print('Account created');
    } catch (e) {
      print('Error creating account: $e');
    }
  }

  Future<void> login(AuthModel userModel) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );
      print('Login successfully');
    } catch (e) {
      print('Error logging in: $e');
    }
  }

  Future<UserCredential?> googleLogin() async {
    try {
      final result = await googleSignIn.signIn();
      if (result == null) {
        throw Exception('Google sign in error');
      }
      final userData = await result.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: userData.accessToken,
        idToken: userData.idToken,
      );
      final finalResult = await firebaseAuth.signInWithCredential(credential);
      return finalResult;
    } catch (e) {
      print('Error during Google sign in: $e');
      rethrow;
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber,
      Function(String) codeSent,
      Function(FirebaseAuthException) verificationFailed,
      ) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: verificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      print('Error verifying phone number: $e');
    }
  }

  Future<void> signInWithOtp(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with OTP: $e');
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
    }
  }
}
