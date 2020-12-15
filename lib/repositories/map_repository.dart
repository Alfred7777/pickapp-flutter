import 'dart:convert';
import 'package:PickApp/main.dart';
import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:PickApp/client.dart';

class MapRepository {
  Future<List<EventMarker>> getEventMap([String disciplineId]) async {
    final client = AuthenticatedApiClient();
    var url;
    if (disciplineId != null) {
      url = 'map?discipline_id=${disciplineId}';
    } else {
      url = 'map';
    }

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var locationList =
          json.decode(response.body).map<EventMarker>((eventMarkerJson) {
        return EventMarker(
          id: eventMarkerJson['id'],
          position: LatLng(eventMarkerJson['lat'], eventMarkerJson['lon']),
          disciplineID: eventMarkerJson['discipline_id'],
        );
      }).toList();
      return locationList;
    } else {
      throw Exception(
        'We can\'t show you events map right now. Please try again later.',
      );
    }
  }
}

Future<BitmapDescriptor> getEventMarkerIcon(String disciplineID) {
  var screenSize = MediaQuery.of(navigatorKey.currentContext).size;
  if (disciplineID == null) {
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio:
            MediaQuery.of(navigatorKey.currentContext).devicePixelRatio,
        size: Size(
          0.05 * screenSize.width,
          0.05 * screenSize.width,
        ),
      ),
      'assets/images/marker/event_group_marker.png',
    );
  } else {
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio:
            MediaQuery.of(navigatorKey.currentContext).devicePixelRatio,
        size: Size(
          0.05 * screenSize.width,
          0.05 * screenSize.width,
        ),
      ),
      'assets/images/marker/${disciplineID}.png',
    );
  }
}

class EventMarker extends Clusterable {
  final String id;
  final LatLng position;
  final String disciplineID;

  EventMarker({
    @required this.id,
    @required this.position,
    @required this.disciplineID,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  Future<Marker> toMarker(
    Function zoomCluster,
    Function showDetails,
  ) async {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: await getEventMarkerIcon(disciplineID),
      onTap: isCluster ? () => zoomCluster(clusterId) : () => showDetails(id),
    );
  }
}
