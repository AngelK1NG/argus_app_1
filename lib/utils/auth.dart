import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

class AuthProvider {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    return user == null
        ? User(signedIn: false)
        : User(signedIn: true, uid: user.uid, email: user.email);
  }

  Stream<User> onAuthStateChanged() {
    return _auth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await GoogleSignIn().signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;
      print("Login successful, uid: " + user.uid);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<FirebaseUser> appleSignIn() async {
    if (!await AppleSignIn.isAvailable()) {
      return null; //Break from the program
    } else {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            final appleIdCredential = result.credential;
            final oAuthProvider = OAuthProvider(providerId: 'apple.com');
            final credential = oAuthProvider.getCredential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode),
            );
            AuthResult authResult =
                await _auth.signInWithCredential(credential);
            FirebaseUser firebaseUser = authResult.user;
            if (appleIdCredential.fullName.givenName != null &&
                appleIdCredential.fullName.familyName != null) {
              final updateUser = UserUpdateInfo();
              updateUser.displayName =
                  '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
              await firebaseUser.updateProfile(updateUser);
            }
            print("Login successful, uid: " + firebaseUser.uid);
            return firebaseUser;
          }
        case AuthorizationStatus.error:
          {
            print(result.error.toString());
            break;
          }
        case AuthorizationStatus.cancelled:
          {
            break;
          }
      }
      return null;
    }
  }
}

class User {
  final bool signedIn;
  final String uid;
  final String email;

  const User({@required this.signedIn, this.uid, this.email});
}
