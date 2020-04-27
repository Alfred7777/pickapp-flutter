import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'add_event_menu.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();

  AnimationController _animationController;

  static final CameraPosition _kPoznan =
      CameraPosition(target: LatLng(52.4064, 16.9252), zoom: 13);

  List<AddEventMenuButton> menu;

  Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _buildAddEventMenu();
    markers = {};
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    stderr.writeln(markers);

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: markers,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _kPoznan,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: 1,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: _buildMenu(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        unselectedLabelStyle:
            TextStyle(color: Colors.black, decorationColor: Colors.black),
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text('My events'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), title: Text('Groups')),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              backgroundColor: Colors.green,
              title: Text('Alerts'))
        ],
      ),
    );
  }

  void _buildAddEventMenu() {
    menu = [
      AddEventMenuButton(
          action: () => _createEvent(),
          icon: Icons.business,
          label: 'Event',
          color: Colors.orange),
      AddEventMenuButton(
          action: () => _createEvent(),
          icon: Icons.room,
          label: 'Event',
          color: Colors.purple)
    ];
  }

  Widget _buildMenu(BuildContext context) {
    var foregroundColor = Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(menu.length, (int index) {
        Widget child = Container(
          padding: EdgeInsets.only(bottom: 10),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.fastOutSlowIn,
            ),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: menu[index].color,
              mini: false,
              child: Icon(menu[index].icon, color: foregroundColor),
              onPressed: () {
                menu[index].action();
                _animationController.reverse();
              },
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.green,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform: Matrix4.rotationZ(
                      _animationController.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: Icon(_animationController.isDismissed
                      ? Icons.add
                      : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),
    );
  }

  void _createEvent() async {
    final marker = Marker(
      markerId: MarkerId('1'),
      position: LatLng(52.46, 16.92),
      infoWindow: InfoWindow(title: '1', snippet: '*'),
    );

    setState(() {
      markers.add(marker);
      stderr.writeln(markers);
    });
  }
}
