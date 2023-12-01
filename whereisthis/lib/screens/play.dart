import 'postgame.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:math';

List<double> photoLatitudes = [];
List<double> photoLongitudes = [];
int currIndex = 0;
double totalScore = 0;
LatLng? tappedLocation;

double dp(double val, int places) {
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  late List<String> photoUrls;
  late Map<String, GeoPoint> photoLocations;
  bool isLoading = true;
  GeoPoint markerLocation = const GeoPoint(0, 0);
  late AnimationController _animationController;

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    backgroundColor: Colors.blue[800],
    side: const BorderSide(width: 2, color: Colors.blue),
    fixedSize: const Size(140, 35),
    shadowColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    resetGame();
    fetchRandomPhotosAndLocations();
  }

  void resetGame() {
    currIndex = 0;
    totalScore = 0;
    currIndex = 0;
    photoUrls = [];
    photoLocations = {};
  }

  Future<void> fetchRandomPhotosAndLocations() async {
    try {
      DocumentSnapshot userDocument = await FirebaseFirestore.instance
          .collection('communityPhotos')
          .doc('commPhotosId')
          .get();

      List<String> allUrls = List<String>.from(userDocument['url'] ?? []);
      Map<String, GeoPoint> allLocations =
          Map<String, GeoPoint>.from(userDocument['locations'] ?? {});

      Set<int> selectedIndices = Set<int>();
      while (selectedIndices.length < 5) {
        selectedIndices.add(
            (DateTime.now().millisecondsSinceEpoch % allUrls.length).toInt());
      }

      photoUrls = selectedIndices.map((index) => allUrls[index]).toList();

      photoLatitudes = selectedIndices
          .map((index) => allLocations[allUrls[index]]?.latitude ?? 0)
          .toList();

      photoLongitudes = selectedIndices
          .map((index) => allLocations[allUrls[index]]?.longitude ?? 0)
          .toList();

      //print(photoLatitudes);
      //print(photoLongitudes);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching photos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void onNextPressed() {
    setState(() {
      if (photoUrls.isNotEmpty && currIndex < photoUrls.length - 1) {
        currIndex++;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DoneScreen(),
          ),
        );
      }
    });
  }

  void calculateScore() {
    double photoLatitude = photoLatitudes[currIndex];
    double photoLongitude = photoLongitudes[currIndex];
    double latitudeDiff =
        pow((photoLatitude - tappedLocation!.latitude).abs(), 2).toDouble();
    double longitudeDiff =
        pow((photoLongitude - tappedLocation!.longitude).abs(), 2).toDouble();
    double currDiff = sqrt(latitudeDiff + longitudeDiff);

    currDiff = 100 - (10 * (currDiff * 1000));
    if (currDiff < 0) {
      currDiff = 0;
    }

    totalScore = (totalScore + currDiff);

    totalScore = dp(totalScore, 2);
    print("lat: $photoLatitude");
    print("long: $photoLongitude");
    print("diff: $currDiff");
    print("total: $totalScore");
  }

  void onMapSubmit() {
    calculateScore();
    onNextPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Positioned.fill(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Image.network(
                    photoUrls.isNotEmpty ? photoUrls[currIndex] : '',
                    fit: BoxFit.cover,
                  ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: kToolbarHeight),
                if (photoUrls.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          right: 16.0,
                          top: 60.0,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Score: ${totalScore.toString()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            onSubmit: onMapSubmit,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("Guess"),
                                    style: style,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final VoidCallback onSubmit;

  MapScreen({required this.onSubmit});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  void onNextPressed() {
    setState(() {
      if (currIndex < 4) {
        //currIndex++;
        widget.onSubmit();
        Navigator.pop(context);
      } else {
        double photoLatitude = photoLatitudes[currIndex];
        double photoLongitude = photoLongitudes[currIndex];
        double latitudeDiff =
            pow((photoLatitude - tappedLocation!.latitude).abs(), 2).toDouble();
        double longitudeDiff =
            pow((photoLongitude - tappedLocation!.longitude).abs(), 2)
                .toDouble();
        double currDiff = sqrt(latitudeDiff + longitudeDiff);

        currIndex = 0;
        currDiff = 100 - (10 * (currDiff * 1000));
        if (currDiff < 0) {
          currDiff = 0;
        }

        totalScore = (totalScore + currDiff);

        totalScore = dp(totalScore, 2);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoneScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(39.727551164068764, -121.84759163416642),
                zoom: 16.0,
              ),
              markers: _markers,
              onTap: (LatLng location) {
                _addMarker(location);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onNextPressed();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng location) {
    final marker = Marker(
      markerId: MarkerId(location.toString()),
      position: location,
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
      tappedLocation = location;
    });
  }
}
