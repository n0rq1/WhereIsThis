import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  void getHighscoreList() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }

    final uid = user.uid;

    DocumentSnapshot userDocument =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDocument.exists) {
      List<double> highscores =
          List<double>.from(userDocument['highscores'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Top Scores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Column(
                children: [
                  buildScoreItem(1, 500),
                  buildScoreItem(2, 500),
                  buildScoreItem(3, 500),
                  buildScoreItem(4, 500),
                  buildScoreItem(5, 500),
                  buildScoreItem(6, 500),
                  buildScoreItem(7, 500),
                  buildScoreItem(8, 500),
                  buildScoreItem(9, 500),
                  buildScoreItem(10, 500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScoreItem(int rank, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 50.0),
          Text(
            '$rank.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 75.0),
          Expanded(
            child: Text(
              '$score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
