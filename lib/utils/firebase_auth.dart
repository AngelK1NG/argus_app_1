import 'package:Focal/Screens/HomePage.dart';
import 'package:Focal/Screens/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthProvider {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> googleSignIn() async {
    print('runned');
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) {
        print('no google popup');
        return false;
      }
      AuthResult res = await _auth.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: (await account.authentication).idToken,
              accessToken: (await account.authentication).accessToken));
      if (res.user == null) {
        print('no google account');
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
