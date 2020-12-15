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
    print(response.statusCode);
    print(json.decode(response.body));
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
}

class LocationMarker {}
