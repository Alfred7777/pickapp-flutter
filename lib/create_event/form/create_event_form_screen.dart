import 'package:PickApp/repositories/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'create_event_form_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';

class CreateEventFormScreen extends StatefulWidget {
  final Location location;
  final LatLng pickedPos;

  CreateEventFormScreen({
    @required this.location,
    @required this.pickedPos,
  });

  @override
  State<CreateEventFormScreen> createState() => CreateEventFormScreenState(
        location: location,
        pickedPos: pickedPos,
      );
}

class CreateEventFormScreenState extends State<CreateEventFormScreen> {
  final Location location;
  final LatLng pickedPos;

  CreateEventFormScreenState({
    @required this.location,
    @required this.pickedPos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: CreateEventFormScrollable(
          location: location,
          pickedPos: pickedPos,
        ),
      ),
    );
  }
}
