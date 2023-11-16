import 'package:flutter/material.dart';
import 'screens/addphotos.dart';
import 'screens/play.dart';
import 'screens/settings.dart';

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
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  child: Text("Settings"),
                  style: style,
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => PlayScreen()),
                    );
                  },
                  child: Text("Play"),
                  style: playStyle
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => AddPhotosScreen()),
                    );
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
