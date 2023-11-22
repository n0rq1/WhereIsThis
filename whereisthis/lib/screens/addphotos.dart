import 'package:flutter/material.dart';
import 'package:location/location.dart';


class AddPhotosScreen extends StatelessWidget {
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: BorderSide(width: 2, color: Colors.blue),
    fixedSize: Size(140, 35),
    shadowColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Photos'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPhotos()),
                );
              },
              child: Text("My Photos"),
              style: style,
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPhotos()),
                );
              },
              child: Text("Add"),
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class MyPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Photos'),
      ),
      body: Center(
        child: Text('My Photos Content'),
      ),
    );
  }
}

class AddPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Photos'),
      ),
      body: Center(
        child: Text('Add Photos Content'),
      ),
    );
  }
}