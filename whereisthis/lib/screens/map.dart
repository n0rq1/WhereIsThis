import 'play.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

GeoPoint loc = GeoPoint(0.0, 0.0);

Set<Marker> _markers = {};
GoogleMapController? _mapController;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? tappedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                tappedLocation != null
                    ? '${tappedLocation!.latitude}, ${tappedLocation!.longitude}'
                    : '',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(39.727551164068764, -121.84759163416642),
                zoom: 18.0,
              ),
              markers: _markers,
              onTap: (LatLng location) {
                print('$location');
                _addMarker(location);
              },
            ),
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