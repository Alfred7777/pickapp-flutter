import 'package:flutter/material.dart';
import 'location_details_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';

class LocationDetailsScreen extends StatefulWidget {
  final String locationID;

  LocationDetailsScreen({@required this.locationID});

  @override
  State<LocationDetailsScreen> createState() =>
      LocationDetailsScreenState(locationID: locationID);
}

class LocationDetailsScreenState extends State<LocationDetailsScreen> {
  final String locationID;

  LocationDetailsScreenState({@required this.locationID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: LocationDetailsScrollable(
          locationID: locationID,
          showEvents: true,
        ),
      ),
    );
  }
}
