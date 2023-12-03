import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      // Sign out of the current Google account
      await _googleSignIn.signOut();

      // Prompt the user to select a Google account
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // The user canceled the sign-in process
        return;
      }

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      if (user != null) {
        final uid = user.uid;
        DocumentSnapshot userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!userDocument.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'locations': {},
            'urls': [],
            'highscores': List.filled(10, 0),
          });
        }
        Navigator.pop(context);
        
      } else {
        print('Error signing in');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _handleSignIn(context);
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
