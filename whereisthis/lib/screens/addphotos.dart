import 'package:flutter/material.dart';

class AddPhotosScreen extends StatelessWidget {
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: BorderSide(width: 2, color: Colors.blue),
    fixedSize: Size(140, 35),
    shadowColor: Colors.black,
  );

  final ButtonStyle playStyle = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: BorderSide(width: 2, color: Colors.blue),
    fixedSize: Size(75, 35),
    shadowColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Photos'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyPhotos()),
                    );
                  },
                  child: Text("My Photos"),
                  style: style,
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => AddPhotos()),
                    );
                  },
                  child: Text("Add"),
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

class AddPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Add Photos'),
      ),
    );
  }
}

class MyPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Add Photos'),
      ),
    );
  }
}