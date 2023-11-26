import '../main.dart';
import 'postgame.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late List<String> photoUrls;
  late Map<String, GeoPoint> photoLocations;
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
                              child: ElevatedButton(
                                onPressed: onNextPressed,
                                child: Text("Submit"),
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
