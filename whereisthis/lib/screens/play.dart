import '../main.dart';
import 'postgame.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';


List<double> photoLatitudes = [];
List<double> photoLongitudes = [];
int currIndex = 0;
double totalScore = 0;
int MAXSCORE = 5000;
LatLng? tappedLocation;

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  late List<String> photoUrls;
  late Map<String, GeoPoint> photoLocations;
  int currentIndex = 0;
  bool isLoading = true;
  GeoPoint markerLocation = GeoPoint(0, 0);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    currentIndex = 0;
    totalScore = 0;
    currIndex = 0;
    photoUrls = [];
    photoLocations = {};
    fetchRandomPhotosAndLocations();
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

      print(photoLatitudes);
      print(photoLongitudes);

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
      if (photoUrls.isNotEmpty && currentIndex < photoUrls.length - 1) {
        currentIndex++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoneScreen()),
        );
      }
    });
  }

  double dp(double val, int places){ 
    num mod = pow(10.0, places); 
    return ((val * mod).round().toDouble() / mod); 
  }

  void calculateScore() {
    double photoLatitude = photoLatitudes[currentIndex];
    double photoLongitude = photoLongitudes[currentIndex];
    double latitudeDiff = pow((photoLatitude - tappedLocation!.latitude).abs(), 2).toDouble();
    double longitudeDiff = pow((photoLongitude - tappedLocation!.longitude).abs(), 2).toDouble();
    double currDiff = sqrt(latitudeDiff + longitudeDiff);

    currDiff = 100 - (10*(currDiff * 1000));
    if(currDiff < 0){
      currDiff = 0;
    }

    totalScore = (totalScore + currDiff);

    totalScore = dp(totalScore,2);
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
      body: Stack(
        children: [
          Positioned.fill(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Image.network(
                    photoUrls.isNotEmpty ? photoUrls[currentIndex] : '',
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
                        SizedBox(height: 20),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (photoUrls.isEmpty)
                  Text(
                    'No photos available',
                    style: TextStyle(color: Colors.white),
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
        currIndex++;
        widget.onSubmit();
        Navigator.pop(context);
      } else {
        currIndex = 0;
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
        title: Text('Map Screen'),
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

double getScore(){
  return totalScore;
}