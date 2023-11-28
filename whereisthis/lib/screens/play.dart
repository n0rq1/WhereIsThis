import '../main.dart';
import 'postgame.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  late List<String> photoUrls;
  late Map<String, GeoPoint> photoLocations;
  int currentIndex = 0;
  bool isLoading = true;

  late AnimationController _animationController;
  bool isMapVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
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
      photoLocations = Map.fromEntries(photoUrls.map((url) =>
          MapEntry(url,
              allLocations.containsKey(url) ? allLocations[url]! : GeoPoint(0, 0))));

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

  void onGuessPressed() {
    setState(() {
      isMapVisible = true;
      _animationController.forward();
    });
  }

  void closeMapAndMoveToNextPhoto() {
    setState(() {
      isMapVisible = false;
      _animationController.reverse();
      onNextPressed();
    });
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
          if (isMapVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: GestureDetector(
                onVerticalDragDown: (_) {},
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down),
                        onPressed: closeMapAndMoveToNextPhoto,
                      ),
                      Expanded(
                        child: MapScreen(),
                      ),
                    ],
                  ),
                ),
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
                                    onPressed: onGuessPressed,
                                    child: Text("Guess"),
                                  ),
                                  ElevatedButton(
                                    onPressed: closeMapAndMoveToNextPhoto,
                                    child: Text("Submit"),
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
