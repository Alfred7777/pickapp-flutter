import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'event_repository.dart';
import 'package:PickApp/client.dart';
import 'package:PickApp/utils/string_formatter.dart';

class LocationRepository {
  Future<String> createLocation({
    @required String name,
    @required String description,
    @required List<String> disciplineIDs,
    @required LatLng pos,
  }) async {
    var client = AuthenticatedApiClient();
    var url = 'locations';

    var body = {
      'name': '$name',
      'description': '$description',
      'lat': pos.latitude,
      'lon': pos.longitude,
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Location successfully created.';
    } else {
      return StringFormatter.formatErrors(json.decode(response.body));
    }
  }

  Future<Location> getLocationDetails(String locationID) async {
    var client = AuthenticatedApiClient();
    var url = 'locations/${locationID}';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return Location.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'We can\'t show you this location right now. Please try again later.',
      );
    }
  }

  Future<List<Event>> getEventList(String locationID) async {
    var client = AuthenticatedApiClient();
    var url = 'locations/${locationID}/active_events';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Event>((event) => Event.fromJson(event))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you this location events right now. Please try again later.',
      );
    }
  }

  Future<List<Location>> searchLocation(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'locations/search?phrase=${searchPhrase}';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Location>((location) => Location.fromJson(location))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you search results right now. Please try again later.',
      );
    }
  }
}

class Location {
  final String id;
  final String name;
  final String description;
  final LatLng position;

  const Location({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.position,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      position: LatLng(json['lat'], json['lon']),
    );
  }
}
