import 'package:PickApp/client.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class EventRepository {
  Future<Set<Marker>> getEvents() async {
    Marker _mapEventToMarker(Map<String, dynamic> event) {
      return Marker(
          point: LatLng(event['lat'], event['lon']));
    }

    final client = AuthenticatedApiClient();
    final url = 'map';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Marker>((event) => _mapEventToMarker(event))
          .toSet();
    } else {
      throw Exception('Failed to get event locations');
    }
  }
}
