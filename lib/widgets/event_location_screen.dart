import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'top_bar.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class EventLocationScreen extends StatefulWidget {
  final Event event;

  EventLocationScreen({@required this.event});

  @override
  State<EventLocationScreen> createState() =>
      _EventLocationScreenState(event: event);
}

class _EventLocationScreenState extends State<EventLocationScreen> {
  final Event event;
  Set<Marker> markers = {};
  BitmapDescriptor markerIcon;
  GoogleMapController mapController;
  CameraUpdate initialCameraPos;
  CameraPosition poznanLatLng = CameraPosition(
    target: LatLng(52.4064, 16.9252),
    zoom: 13,
  );
  

  _EventLocationScreenState({@required this.event});

  @override
  void initState() {
    super.initState();

    initialCameraPos = CameraUpdate.newLatLngZoom(event.pos, 17.0);
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/marker/${event.disciplineID}.png',
    ).then((icon) {
      markerIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: markers,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        initialCameraPosition: poznanLatLng,
        onMapCreated: (GoogleMapController controller) async {
          mapController = controller;
          await mapController.moveCamera(initialCameraPos);
          setState(() {
            markers.add(Marker(
              markerId: MarkerId(event.id),
              position: event.pos,
              icon: markerIcon,
            ));
          });
        },
      ),
    );
  }
}
