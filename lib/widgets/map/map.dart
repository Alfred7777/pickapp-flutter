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
  Completer<GoogleMapController> _controller = Completer();

  AnimationController _animationController;

  bool _switch = true;

  static final CameraPosition _kPoznan =
      CameraPosition(target: LatLng(52.4064, 16.9252), zoom: 13);

  List<AddEventMenuButton> menu;

  Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _buildAddEventMenu();
    markers = new Set();
    _animationController = new AnimationController(
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

    return new Scaffold(
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
            new TextStyle(color: Colors.black, decorationColor: Colors.black),
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.public),
            title: new Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.event),
            title: new Text('My events'),
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.people), title: new Text('Groups')),
          BottomNavigationBarItem(
              icon: new Icon(Icons.notifications),
              backgroundColor: Colors.green,
              title: new Text('Alerts'))
        ],
      ),
    );
  }

  void _buildAddEventMenu() {
    menu = [
      AddEventMenuButton(
          action: () => _createEvent(),
          icon: Icons.business,
          label: "Event",
          color: Colors.orange),
      AddEventMenuButton(
          action: () => _createEvent(),
          icon: Icons.room,
          label: "Event",
          color: Colors.purple)
    ];
  }

  Widget _buildMenu(BuildContext context) {
    Color foregroundColor = Colors.white;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(menu.length, (int index) {
        Widget child = new Container(
          padding: EdgeInsets.only(bottom: 10),
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _animationController,
              curve: Curves.fastOutSlowIn,
            ),
            child: new FloatingActionButton(
              heroTag: null,
              backgroundColor: menu[index].color,
              mini: false,
              child: new Icon(menu[index].icon, color: foregroundColor),
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
          new FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.green,
            child: new AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(
                      _animationController.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(_animationController.isDismissed
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
    final Marker marker = Marker(
      markerId: MarkerId("1"),
      position: LatLng(52.46, 16.92),
      infoWindow: InfoWindow(title: "lol", snippet: '*'),
    );

    setState(() {
      markers.add(marker);
      stderr.writeln(markers);
    });
  }
}
