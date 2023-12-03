import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MyPhotosScreen extends StatelessWidget {
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
        child: PhotoGrid(),
      ),
    );
  }
}

class PhotoGrid extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!['urls'] == null) {
          return Center(
            child: Text('No photos available',
                style: TextStyle(color: Colors.white)),
          );
        }

        List<String> allUrls = List<String>.from(snapshot.data!['urls'] ?? []);

        return Container(
          color: Colors.grey[900],
          child: ListView(
            children: [
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: allUrls.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var photoUrl = allUrls[index];
                  return GridTile(
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
