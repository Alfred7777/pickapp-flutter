import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'event_repository.dart';
import 'package:PickApp/client.dart';

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
      return 'Location created';
    } else {
      var errorMessage = '';
      EventRepository()
          .formatErrors(json.decode(response.body)['errors'])
          .forEach((k, v) {
        errorMessage = errorMessage + v + '\n';
      });
      return errorMessage.substring(0, errorMessage.length - 1);
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
      // will be changed when events in location will be fixed
      return [];
    } else {
      return [];
    }
  }

  Future<List<Location>> searchLocation(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'locations/search?phrase=${searchPhrase}';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return json
          .decode(response.body)
          .map<Location>((location) => Location.fromJson(location))
          .toList();
    } else {
      throw Exception(
        'We cannot show you search results right now. Please try again later.',
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
