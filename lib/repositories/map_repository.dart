import 'dart:convert';
import 'package:PickApp/utils/marker_clusters.dart';
import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:PickApp/client.dart';

class MapRepository {
  Future<List<MapMarker>> getMap({
    List<String> disciplineIDs,
    DateTime fromDate,
    DateTime toDate,
    String visibility,
  }) async {
    final client = AuthenticatedApiClient();
    var url = 'map';
    var queryParams = <String, dynamic>{
      'discipline_ids[]': disciplineIDs,
      'from_ms': '${fromDate?.toUtc()?.millisecondsSinceEpoch}',
      'to_ms': '${toDate?.toUtc()?.millisecondsSinceEpoch}',
      'visibility': '$visibility',
    };

    queryParams.removeWhere((key, value) {
      if (key == null || value == null || value == 'null') {
        return true;
      }
      return false;
    });

    var response = await client.get(url, queryParams: queryParams);

    if (response.statusCode == 200) {
      var eventList = json.decode(response.body)['events'];
      var locationList = json.decode(response.body)['locations'];
      var mappedEvents = eventList.map<MapMarker>((eventJson) {
        return MapMarker(
          id: eventJson['id'],
          position: LatLng(
            eventJson['lat'],
            eventJson['lon'],
          ),
          disciplineID: eventJson['discipline_id'],
        );
      }).toList();
      var mappedLocations = locationList.map<MapMarker>((locationJson) {
        return MapMarker(
          id: locationJson['id'],
          position: LatLng(
            locationJson['lat'],
            locationJson['lon'],
          ),
          disciplineID: null,
        );
      }).toList();

      return mappedEvents + mappedLocations;
    } else {
      throw Exception(
        'We can\'t show you map right now. Please try again later.',
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
