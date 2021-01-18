import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PickApp/main.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:PickApp/event_details/event_details_scrollable.dart';
import 'package:PickApp/location_details/location_details_scrollable.dart';

class MarkerClusters {
  static Future<Set<Marker>> getMarkers(
    GoogleMapController mapController,
    Fluster<MapMarker> fluster,
    LatLngBounds mapBounds,
    double zoom,
    bool showDetails,
  ) async {
    var markerSet = <Marker>{};

    var _markerClusters = fluster.clusters([
      mapBounds.southwest.longitude,
      mapBounds.southwest.latitude,
      mapBounds.northeast.longitude,
      mapBounds.northeast.latitude,
    ], zoom.round());

    for (var cluster in _markerClusters) {
      markerSet.add(await cluster.toMarker(
        mapController,
        fluster,
        _zoomCluster,
        !showDetails
            ? _showLocationInfo
            : cluster.disciplineID == null
                ? _showLocationDetails
                : _showEventDetails,
      ));
    }
    return markerSet;
  }

  static void _zoomCluster(
    int clusterID,
    Fluster<MapMarker> fluster,
    GoogleMapController mapController,
  ) async {
    var _clusterLocations = fluster.points(clusterID);
    double x0, x1, y0, y1;

    for (var location in _clusterLocations) {
      var latLng = location.position;
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }

    var clusterBounds = LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );

    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(clusterBounds, 60.0),
    );
  }

  static void _showEventDetails(String eventID) async {
    await showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return Padding(
          padding: EdgeInsets.only(
            top: 0.12 * screenSize.height,
            bottom: 0.02 * screenSize.height,
            left: 0.02 * screenSize.width,
            right: 0.02 * screenSize.width,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: Material(
              color: Colors.grey[100],
              child: EventDetailsScrollable(
                eventID: eventID,
                showButtons: true,
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showLocationDetails(String locationID) async {
    await showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return Padding(
          padding: EdgeInsets.only(
            top: 0.12 * screenSize.height,
            bottom: 0.02 * screenSize.height,
            left: 0.02 * screenSize.width,
            right: 0.02 * screenSize.width,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: Material(
              color: Colors.grey[100],
              child: LocationDetailsScrollable(
                locationID: locationID,
                showEvents: true,
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showLocationInfo(String locationID) async {
    await showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return Padding(
          padding: EdgeInsets.only(
            top: 0.12 * screenSize.height,
            bottom: 0.02 * screenSize.height,
            left: 0.02 * screenSize.width,
            right: 0.02 * screenSize.width,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: Material(
              color: Colors.grey[100],
              child: LocationDetailsScrollable(
                locationID: locationID,
                showEvents: false,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<BitmapDescriptor> getMarkerIcon(
      List<MapMarker> children) async {
    var screenSize = MediaQuery.of(navigatorKey.currentContext).size;
    String path;
    if (children.length == 1) {
      if (children[0].disciplineID == null) {
        path = 'assets/images/markers/location/location_marker.png';
      } else {
        path = 'assets/images/markers/event/${children[0].disciplineID}.png';
      }
    } else {
      var list = mostFrequentMarkers(children);
      list.sort();
      if (list.first == list.last) {
        path = 'assets/images/markers/group/${list.first}.png';
      } else if (list.first == 'location') {
        path = 'assets/images/markers/group/location_${list.last}.png';
      } else if (list.last == 'location') {
        path = 'assets/images/markers/group/location_${list.first}.png';
      } else {
        path = 'assets/images/markers/group/${list.first}_${list.last}.png';
      }
    }
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio:
            MediaQuery.of(navigatorKey.currentContext).devicePixelRatio,
        size: Size(
          0.05 * screenSize.width,
          0.05 * screenSize.width,
        ),
      ),
      path,
    );
  }

  static List<String> mostFrequentMarkers(List<MapMarker> markers) {
    var map = {};
    markers.forEach((x) => map[x.disciplineID] =
        !map.containsKey(x.disciplineID) ? (1) : (map[x.disciplineID] + 1));

    if (map.length == 1) {
      return [map.keys.first ?? 'location', map.keys.first ?? 'location'];
    }

    var key1, key2;
    var max1 = 0, max2 = 0;
    map.forEach((k, v) {
      if (v > max1) {
        max1 = v;
        key1 = k;
      } else if (v > max2) {
        max2 = v;
        key2 = k;
      }
    });
    key1 ??= 'location';
    key2 ??= 'location';

    return [key1, key2];
  }

  static LatLngBounds extendBounds(LatLngBounds bounds) {
    var north = bounds.northeast.latitude;
    var south = bounds.southwest.latitude;
    var west = bounds.southwest.longitude;
    var east = bounds.northeast.longitude;
    var difference = north - south;

    var newNorth = north + 5 * difference;
    var newSouth = south - 5 * difference;
    var newWest = west - 5 * difference;
    var newEast = east + 5 * difference;

    return LatLngBounds(
      northeast: LatLng(
        newNorth > 90 ? 90 : newNorth,
        newEast > 179.99 ? 179.99 : newEast,
      ),
      southwest: LatLng(
        newSouth < -90 ? -90 : newSouth,
        newWest < -180 ? -180 : newWest,
      ),
    );
  }

  static Fluster<MapMarker> initFluster(List<MapMarker> markers) {
    return Fluster<MapMarker>(
      minZoom: 0,
      maxZoom: 20,
      radius: 64,
      extent: 256,
      nodeSize: 64,
      points: markers,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          MapMarker(
        id: UniqueKey().toString(),
        position: LatLng(lat, lng),
        disciplineID: null,
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }
}
