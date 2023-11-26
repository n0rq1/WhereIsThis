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

    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null && imageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );

      try {
        String photoUrl = await uploadFile(Uuid().v1());
        DocumentSnapshot userDocument = await FirebaseFirestore.instance
            .collection('communityPhotos')
            .doc('commPhotosId')
            .get();

        List<String> currentUrls =
          List<String>.from(userDocument['url'] ?? []);

        Map<String,GeoPoint> locationsMap = 
          Map<String,GeoPoint>.from(userDocument['locations'] ?? [] );

        currentUrls.insert(0, photoUrl);

        locationsMap[photoUrl] = GeoPoint(position!.latitude,position!.longitude);

        final docRef =
            firestore.collection('communityPhotos').doc('commPhotosId');
        await docRef.set({
          'locations': locationsMap,
          'url': currentUrls,
        });

        DocumentSnapshot userP = await FirebaseFirestore.instance
            .collection('userPhotos')
            .doc(auth.currentUser!.uid)
            .collection('photos')
            .doc('photosId')
            .get();

        List<String> userUrls =
            List<String>.from(userP['url'] ?? []);
        List<GeoPoint> userLocations =
            List<GeoPoint>.from(userP['location'] ?? []);

        userUrls.insert(0, photoUrl);
        userLocations.insert(0, GeoPoint(position!.latitude, position!.longitude));

        final test = 
        firestore.collection('userPhotos').doc(auth.currentUser!.uid).collection('photos').doc('photosId');
        await test.set({
          'url': userUrls,
          'location': userLocations,
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
          const SnackBar(content: Text('Please take a photo before submitting')),
        );
      } else {
        print('User not signed in');
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
        // title: Text("Add a Photo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (imageFile != null) // Show "Submit" button only if a photo is taken
              ElevatedButton(
                onPressed: buttonWorks ? _submit : null,
                child: const Icon(Icons.cloud_upload),
              ),
            ElevatedButton(
              onPressed: _navigateToMyPhotos, // Redirect to MyPhotos screen
              child: const Text("My Photos"),
            ),
            Text(displayString),
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
