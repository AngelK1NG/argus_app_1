import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider {
  FirebaseAuth _auth = FirebaseAuth.instance;

  UserStatus _userFromFirebase(User user) {
    return user == null
        ? UserStatus(signedIn: false)
        : UserStatus(signedIn: true, uid: user.uid, email: user.email);
  }

  Stream<UserStatus> onAuthStateChanged() {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future<User> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await GoogleSignIn().signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user;
      print("Login successful, uid: " + user.uid);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<User> appleSignIn() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );
      UserCredential result = await _auth.signInWithCredential(oauthCredential);
      User user = result.user;
      print("Login successful, uid: " + user.uid);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }
}

class UserStatus {
  final bool signedIn;
  final String uid;
  final String email;

  const UserStatus({@required this.signedIn, this.uid, this.email});
}
