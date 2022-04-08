import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  // ignore: unused_field
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
     if(kIsWeb){
       GoogleAuthProvider googleProvider = GoogleAuthProvider();

       googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
       googleProvider.setCustomParameters({
         'login_hint': 'allgotest@8008@gmail.com'
       });

       // Once signed in, return the UserCredential
       return await FirebaseAuth.instance.signInWithPopup(googleProvider);
     }
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error is 😂😂😂😁😀😀 ${e.toString()}");
    }
    notifyListeners();
  }

  Future googleSignOut() async {
    try {
      await googleSignIn.disconnect();
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error is 😂😂😂😁😀😀 ${e.toString()}");
    }
    notifyListeners();
  }
}
