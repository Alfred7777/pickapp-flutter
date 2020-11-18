import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'userRepository.dart';
import 'package:collection/collection.dart';
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
      'discipline_id': '$disciplineID'
    };

    var response = await client.post('events', body: body);
    if (response.statusCode == 201) {
      return 'Event created';
    } else {
      throw Exception('Could not create event');
    }
  }

  // For sure this could be improved ;)
  String beautifyErrorResponse(String responseBody) {
    var errors = Map<String, dynamic>.from(json.decode(responseBody)['errors']);
    var error_formatted = '';

    errors.forEach((key, value) {
      error_formatted = error_formatted +
          key.toString() +
          ' ' +
          value.toString().replaceAll('[', '').replaceAll(']', '') +
          ' ' +
          '\n';
    });

    return error_formatted;
  }

  Future<String> updateEvent({
    final String name,
    final String description,
    final String disciplineID,
    final String eventID,
    final DateTime startDate,
    final DateTime endDate,
  }) async {
    var startDatetime = startDate?.toUtc()?.millisecondsSinceEpoch;
    var endDatetime = endDate?.toUtc()?.millisecondsSinceEpoch;
    var client = AuthenticatedApiClient();

    var new_details = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDatetime,
      'end_datetime_ms': endDatetime,
      'discipline_id': '$disciplineID',
    };

    new_details.removeWhere(
        (key, value) => key == null || value == null || value == 'null');

    var body = {
      'new_details': new_details,
    };

    var response = await client.post('events/$eventID/edit', body: body);
    if (response.statusCode == 201) {
      return 'Event updated';
    } else {
      throw Exception(beautifyErrorResponse(response.body));
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
        'start_date': DateTime.fromMillisecondsSinceEpoch(
          details['start_datetime_ms'],
        ),
        'end_date': DateTime.fromMillisecondsSinceEpoch(
          details['end_datetime_ms'],
        ),
        'discipline_id': details['discipline_id'],
        'organiser_id': details['organiser_id'],
        'is_participant': details['is_participating?'],
      };
    } else {
      throw Exception(
          'We cannot show you this event right now. Please try again later.');
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

  Future<String> inviteToEvent(String eventID, String inviteeID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/invite';
    var body = {
      'invitee_id': '$inviteeID',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode == 201) {
      return 'Successfully invited user to event.';
    } else {
      return json.decode(response.body)['message'];
    }
  }

  Future<List<User>> getParticipants(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participants';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<User>((participant) => User.fromJson(participant))
          .toList();
    } else {
      return [];
    }
  }

  Future<Map<DateTime, List<Event>>> getMyEvents(String eventsType) async {
    final client = AuthenticatedApiClient();

    final url = 'user_dashboard/${eventsType}_events';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      List<Event> eventList = json
          .decode(response.body)
          .map<Event>((event) => Event.fromJson(event))
          .toList();
      return groupBy(
          eventList,
          (event) => DateTime(event.startDate.year, event.startDate.month,
              event.startDate.day));
    } else {
      return {};
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

class Event {
  final String id;
  final String name;
  final String description;
  final String disciplineID;
  final LatLng pos;
  final DateTime startDate;
  final DateTime endDate;

  Event(
    this.id,
    this.name,
    this.description,
    this.disciplineID,
    this.pos,
    this.startDate,
    this.endDate,
  );

  factory Event.fromJson(Map<String, dynamic> json) {
    print(json);
    return Event(
      json['id'],
      json['name'],
      json['description'],
      json['discipline_id'],
      LatLng(json['lat'], json['lon']),
      DateTime.fromMillisecondsSinceEpoch(json['start_datetime_ms']),
      DateTime.fromMillisecondsSinceEpoch(json['end_datetime_ms']),
    );
  }
}
