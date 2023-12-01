import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
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
                  buildScoreItem(2, 499),
                  buildScoreItem(3, 484),
                  buildScoreItem(4, 483),
                  buildScoreItem(5, 480),
                  buildScoreItem(6, 475),
                  buildScoreItem(7, 473),
                  buildScoreItem(8, 460),
                  buildScoreItem(9, 420),
                  buildScoreItem(10, 410),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScoreItem(int rank, int score) {
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
