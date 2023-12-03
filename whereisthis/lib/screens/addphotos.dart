import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'myphotos.dart';

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key});
  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  bool buttonWorks = true;
  String displayString = "";
  late Future<Position> _futurePosition;
  late Stream<Position> positionStream;
  final ImagePicker picker = ImagePicker();
  File? imageFile;
  String url = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: BorderSide(width: 2, color: Colors.blue),
    fixedSize: Size(140, 35),
    shadowColor: Colors.black,
  );

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _futurePosition = _determinePosition();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  void _getPhoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
      });
    }
  }

  Position? position;

  Future<void> _getPosition() async {
    position = await _futurePosition;
    print('Latitude: ${position?.latitude}, Longitude: ${position?.longitude}');
  }

  void _submit() async {
    await _getPosition();

    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null && imageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Processing Data',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      try {
        String photoUrl = await uploadFile(Uuid().v1());

        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        if (user == null) {
          return;
        }

        final uid = user.uid;

        //get community photos/locations
        DocumentSnapshot commDocument = await FirebaseFirestore.instance
            .collection('communityPhotos')
            .doc('commPhotosId')
            .get();

        //community photo urls
        List<String> commUrls = List<String>.from(commDocument['urls'] ?? []);

        //community photo geopoints
        Map<String, GeoPoint> commLocations =
            Map<String, GeoPoint>.from(commDocument['locations'] ?? []);

        //add current photoUrl to the top of the commUrls
        commUrls.insert(0, photoUrl);

        //add currentPhotoUrl location to the top of the commLocations
        commLocations[photoUrl] =
            GeoPoint(position!.latitude, position!.longitude);

        //get user photos/locations
        DocumentSnapshot userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        List<String> userUrls = List<String>.from(userDocument['urls'] ?? []);

        Map<String, GeoPoint> userLocations =
            Map<String, GeoPoint>.from(userDocument['locations'] ?? []);

        userUrls.insert(0, photoUrl);

        userLocations[photoUrl] =
            GeoPoint(position!.latitude, position!.longitude);

        //insert into comm photos
        final docRefComm =
            firestore.collection('communityPhotos').doc('commPhotosId');
        await docRefComm.update({
          'locations': commLocations,
          'urls': commUrls,
        });

        //insert into user photos
        final docRefUser =
            firestore.collection('users').doc(uid);
        await docRefUser.update({
          'locations': userLocations,
          'urls': userUrls,
        });

        print('Success.');

        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            imageFile = null;
          });
        });
      } catch (e) {
        print('$e');
      }
    } else {
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Take a photo to submit')),
        );
      }
    }
  }

  Future<String> uploadFile(String filename) async {
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: <String, String>{'file': 'image'},
      contentLanguage: 'en',
    );
    UploadTask uploadTask = ref.putFile(imageFile!, metadata);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    if (kDebugMode) {
      print(downloadURL);
    }
    return downloadURL;
  }

  void _navigateToMyPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyPhotosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (imageFile != null)
              ElevatedButton(
                onPressed: buttonWorks ? _submit : null,
                child: const Icon(Icons.cloud_upload),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToMyPhotos,
              child: const Text("My Photos"),
              style: style,
            ),
            SizedBox(height: 16),
            Text(displayString),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPhoto,
        tooltip: 'Get Photo',
        child: const Icon(Icons.add_a_photo),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
