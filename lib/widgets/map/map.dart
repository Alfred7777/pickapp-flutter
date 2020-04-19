import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'add_event_menu.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  bool _switch = true;

  static final CameraPosition _kPoznan =
      CameraPosition(target: LatLng(52.4064, 16.9252), zoom: 13);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _kPoznan,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _toggle,
          backgroundColor: Colors.green,
          tooltip: "jazda!"),
    );
  }

  void _toggle() {
    _switch = !_switch; 
  }

  // void _buildAddEventMenu() {
  //   menu = [
  //     AddEventMenuButton(
  //       action: () => _createEvent(),
  //       icon: Icons.room,
  //       label: "Event"
  //     )
  //   ]
  // }
}