import 'dart:convert';
import 'package:PickApp/utils/marker_clusters.dart';
import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:PickApp/client.dart';

class MapRepository {
  Future<List<MapMarker>> getEventMap([String disciplineId]) async {
    final client = AuthenticatedApiClient();
    var url;
    if (disciplineId != null) {
      url = 'map?discipline_id=${disciplineId}';
    } else {
      url = 'map';
    }

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var eventList =
          json.decode(response.body).map<MapMarker>((eventMarkerJson) {
        return MapMarker(
          id: eventMarkerJson['id'],
          position: LatLng(
            eventMarkerJson['lat'],
            eventMarkerJson['lon'],
          ),
          disciplineID: eventMarkerJson['discipline_id'],
        );
      }).toList();
      return eventList;
    } else {
      throw Exception(
        'We can\'t show you events map right now. Please try again later.',
      );
    }
  }

  Future<List<MapMarker>> getLocationMap() async {
    final client = AuthenticatedApiClient();
    var url = 'locations/get';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var locationList =
          json.decode(response.body).map<MapMarker>((locationMarkerJson) {
        return MapMarker(
          id: locationMarkerJson['id'],
          position: LatLng(
            locationMarkerJson['lat'],
            locationMarkerJson['lon'],
          ),
          disciplineID: null,
        );
      }).toList();
      return locationList;
    } else {
      throw Exception(
        'We can\'t show you locations map right now. Please try again later.',
      );
    }
  }
}

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final String disciplineID;

  MapMarker({
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
    GoogleMapController mapController,
    Fluster<MapMarker> fluster,
    Function zoomCluster,
    Function showDetails,
  ) async {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: await MarkerClusters.getMarkerIcon(
        fluster.points(clusterId).isEmpty ? [this] : fluster.points(clusterId),
      ),
      onTap: isCluster
          ? () => zoomCluster(clusterId, fluster, mapController)
          : () => showDetails(id),
    );
  }
}
