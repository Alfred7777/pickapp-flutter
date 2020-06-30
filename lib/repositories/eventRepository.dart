import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'userRepository.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:PickApp/client.dart';

class EventRepository {
  Future<String> createEvent({
    @required String name,
    @required String description,
    @required String disciplineID,
    @required LatLng pos,
    @required DateTime startDate,
    @required DateTime endDate,
  }) async {
    var userID = '30046e37-9187-45de-82f2-8964004b119c';
    var startDatetime = startDate.toUtc().millisecondsSinceEpoch;
    var endDatetime = endDate.toUtc().millisecondsSinceEpoch;
    var lat = pos.latitude;
    var lon = pos.longitude;
    var client = AuthenticatedApiClient();

    var body = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDatetime,
      'end_datetime_ms': endDatetime,
      'lat': lat,
      'lon': lon,
      'organiser_id': '$userID',
      'discipline_id': '$disciplineID'
    };

    var response = await client.post('events', body: body);
    if (response.statusCode == 201) {
      return 'Event created';
    } else {
      throw Exception('Could not create event');
    }
  }

  Future<Set<Location>> getMap() async {
    final client = AuthenticatedApiClient();
    final url = 'map';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Location>((locationJson) => Location.fromJson(locationJson))
          .toSet();
    } else {
      throw Exception('Failed to fetch map');
    }
  }

  Future<Map<String, dynamic>> getEventDetails(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var details = json.decode(response.body);
      return {
        'name': details['name'],
        'description': details['description'],
        'start_date':
            DateTime.fromMillisecondsSinceEpoch(details['start_datetime_ms']),
        'end_date':
            DateTime.fromMillisecondsSinceEpoch(details['end_datetime_ms']),
        'discipline_id': details['discipline_id'],
        'organiser_id': details['organiser_id'],
        'is_participant': details['is_participating?'],
      };
    } else {
      throw Exception('Event not found in database');
    }
  }

  Future<Set<Location>> filterMapByDiscipline(disciplineId) async {
    final client = AuthenticatedApiClient();
    final url = 'map?discipline_id=${disciplineId}';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Location>((locationJson) => Location.fromJson(locationJson))
          .toSet();
    } else {
      throw Exception('Failed to fetch map');
    }
  }

  Future<List<Discipline>> getDisciplines() async {
    final client = AuthenticatedApiClient();
    final url = 'disciplines';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Discipline>((discipline) => Discipline.fromJson(discipline))
          .toList();
    } else {
      throw Exception('Failed to get disciplines');
    }
  }

  Future<String> joinEvent(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participants';
    var body = {
      'event_id': '$eventID',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Successfully joined event.';
    } else {
      return json.decode(response.body)['message'];
    }
  }

  Future<List<Profile>> getParticipants(String eventID) async {
    Profile mapParticipantToProfile(Map<String, dynamic> participant) {
      return Profile(
        bio: participant['bio'],
        name: participant['name'],
        uniqueUsername: participant['unique_username'],
      );
    }

    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participants';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Profile>((participant) => mapParticipantToProfile(participant))
          .toList();
    } else {
      return [];
    }
  }
}

class Location {
  final String id;
  final double lat;
  final double lon;
  final String disciplineID;

  Location({this.id, this.lat, this.lon, this.disciplineID});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      lat: json['lat'],
      lon: json['lon'],
      disciplineID: json['discipline_id'],
    );
  }
}

class Discipline {
  final String id;
  final String name;
  Discipline(this.id, this.name);

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(json['id'], json['name']);
  }
}
