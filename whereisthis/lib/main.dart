import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: Colors.blue[800],
      side: BorderSide(width: 2, color:Colors.blue),
      fixedSize: Size(140,35),
      shadowColor: Colors.black,
    );

    final ButtonStyle playStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: Colors.blue[800],
      side: BorderSide(width: 2, color:Colors.blue),
      fixedSize: Size(75,35),
      shadowColor: Colors.black,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/ButteHomeScreen.png',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Settings button click
                  },
                  child: Text("Settings"),
                  style: style,
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle Play button click
                  },
                  child: Text("Play"),
                  style: playStyle
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle Scores button click
                  },
                  child: Text("Add Photos"),
                  style: style,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
