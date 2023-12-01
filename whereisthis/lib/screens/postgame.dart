import '../main.dart';
import 'play.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DoneScreen extends StatefulWidget {
  @override
  _DoneScreenState createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: BorderSide(width: 2, color: Colors.blue),
    fixedSize: Size(140, 35),
    shadowColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    fetchHighScores();
  }

  Future<void> fetchHighScores() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      if (user == null) {
        return;
      }

      final uid = user.uid;

      DocumentSnapshot userDocument =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDocument.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'highscores': [totalScore, ...List<double>.filled(9, 0)],
        });
      } else {
        List<double> highscores =
            List<double>.from(userDocument['highscores'] ?? []);

        for (int i = 0; i < 10; i++) {
          if (i < highscores.length) {
            if (totalScore > highscores[i]) {
              highscores.insert(i, totalScore);
              if (highscores.length > 10) {
                highscores.removeLast();
              }
              break;
            }
          } else {
            highscores.add(totalScore);
            break;
          }
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'highscores': highscores,
        });
      }
    } catch (e) {
      print('Error updating high scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Final Score",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]),
              ),
              SizedBox(height: 20),
              Text(
                "$totalScore",
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PlayScreen()),
                  );
                },
                child: Text("New Game"),
                style: style,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text("Home"),
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
