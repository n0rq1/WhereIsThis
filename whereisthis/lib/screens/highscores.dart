import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HighscoresScreen extends StatefulWidget {
  @override
  _HighscoresScreenState createState() => _HighscoresScreenState();
}

List<double> highscores = List.filled(10, 0);

class _HighscoresScreenState extends State<HighscoresScreen> {
  @override
  void initState() {
    super.initState();
    getHighscoreList();
  }

  Future<void> getHighscoreList() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }

    final uid = user.uid;

    DocumentSnapshot userDocument =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDocument.exists) {
      setState(() {
        highscores = List<double>.from(userDocument['highscores'] ?? []);
      });
    }
  }

  Future<void> resetStats() async {
    setState(() {
      highscores = List<double>.filled(10, 0);
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }

    final uid = user.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'highscores': highscores,
    });
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
                  buildScoreItem(1, highscores[0]),
                  buildScoreItem(2, highscores[1]),
                  buildScoreItem(3, highscores[2]),
                  buildScoreItem(4, highscores[3]),
                  buildScoreItem(5, highscores[4]),
                  buildScoreItem(6, highscores[5]),
                  buildScoreItem(7, highscores[6]),
                  buildScoreItem(8, highscores[7]),
                  buildScoreItem(9, highscores[8]),
                  buildScoreItem(10, highscores[9]),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showResetConfirmationDialog(),
        label: Text('Reset'),
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

  void showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reset Stats"),
          content: Text("Are you sure you want to reset your stats?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                resetStats();
                Navigator.of(context).pop();
              },
              child: Text("Reset"),
            ),
          ],
        );
      },
    );
  }
}
