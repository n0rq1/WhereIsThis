import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key});

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool buttonWorks = true;
  String displayString = "";
  late Future<Position> _futurePosition;
  late Stream<Position> positionStream;
  final ImagePicker picker = ImagePicker();
  File? imageFile;
  String url = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
  }

  void _submit() async {
    await _getPosition();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data')),
    );

/*
    try {
      final docRef = firestore.collection('photos').doc('photoId');
      await docRef.set({
          'location': GeoPoint(position!.latitude, position!.longitude),
          'url': "test",
          'user': FirebaseAuth.instance.currentUser!.uid,
        });
        print('Success.');
      } catch (e) {
        print('$e');
      }*/
    DocumentSnapshot userDocument =
    await FirebaseFirestore.instance.collection('communityPhotos').doc('commPhotosId').get();

    List<String> currentUrls = List<String>.from(userDocument['url'] ?? []);
    List<GeoPoint> currentLocations = List<GeoPoint>.from(userDocument['location'] ?? []);
    currentUrls.insert(0, "Ab");
    GeoPoint geoPoint = GeoPoint(37.7749, -122.4194);
    currentLocations.insert(0, geoPoint);

    if (position != null) {
      try {
        final docRef = 
        firestore.collection('communityPhotos').doc('commPhotosId');
        await docRef.set({
          'location': currentLocations,
          'url': currentUrls,
        });
        print('Success.');
      } catch (e) {
        print('$e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Photo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: buttonWorks ? _submit : null,
              child: const Text("Submit"),
            ),
            Text(displayString),
            SizedBox(
              height: 200,
              width: 200,
              child: imageFile != null
                  ? Image.file(imageFile!)
                  : Placeholder(
                      fallbackHeight: 100,
                      fallbackWidth: 100,
                      child: Image.network(
                        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                      ),
                    ),
            ),
            FutureBuilder<Position>(
              future: _futurePosition,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'Lat: ${snapshot.data!.latitude}, Long: ${snapshot.data!.longitude}, Accuracy: ${snapshot.data!.accuracy}');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                return const CircularProgressIndicator();
              },
            ),
            StreamBuilder<Position>(
              stream: positionStream,
              builder:
                  (BuildContext context, AsyncSnapshot<Position> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'Lat: ${snapshot.data!.latitude}, Long: ${snapshot.data!.longitude}, Accuracy: ${snapshot.data!.accuracy}');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPhoto,
        tooltip: 'Get Photo',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
