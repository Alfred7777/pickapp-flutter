import 'package:PickApp/event_details/event_details_scrollable.dart';
import 'package:PickApp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluster/fluster.dart';
import 'user_repository.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:PickApp/client.dart';

class EventRepository {
  Map<String, dynamic> formatErrors(Map<String, dynamic> errors) {
    var errorsMap = <String, dynamic>{};
    errors.keys.forEach((key) {
      var errorMessage = '';
      errors[key].forEach((message) {
        if (message.contains('blank')) {
          errorMessage = errorMessage +
              '${key[0].toUpperCase()}${key.substring(1)} is required!\n';
        } else {
          errorMessage = errorMessage + message + '\n';
        }
      });
      errorsMap[key] = errorMessage.substring(0, errorMessage.length - 1);
    });
    return errorsMap;
  }

  Future<String> createEvent({
    @required String name,
    @required String description,
    @required String disciplineID,
    @required LatLng pos,
    @required DateTime startDate,
    @required DateTime endDate,
    // event privacy settings
    @required bool allowInvitations,
    @required bool requireParticipationAcceptation,
  }) async {
    var client = AuthenticatedApiClient();

    var body = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDate.toUtc().millisecondsSinceEpoch,
      'end_datetime_ms': endDate.toUtc().millisecondsSinceEpoch,
      'lat': pos.latitude,
      'lon': pos.longitude,
      'discipline_id': '$disciplineID',
      'settings': {
        'allow_invitations': allowInvitations,
        'require_participation_acceptation': requireParticipationAcceptation,
      },
    };

    var response = await client.post('events', body: body);
    if (response.statusCode == 201) {
      return 'Event created';
    } else {
      var errorMessage = '';
      formatErrors(json.decode(response.body)['errors']).forEach((k, v) {
        errorMessage = errorMessage + v + '\n';
      });
      return errorMessage.substring(0, errorMessage.length - 1);
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
    // event privacy settings
    final bool allowInvitations,
    final bool requireParticipationAcceptation,
  }) async {
    var startDatetime = startDate?.toUtc()?.millisecondsSinceEpoch;
    var endDatetime = endDate?.toUtc()?.millisecondsSinceEpoch;
    var client = AuthenticatedApiClient();

    var new_settings = {
      'allow_invitations': allowInvitations,
      'require_participation_acceptation': requireParticipationAcceptation,
    };

    new_settings.removeWhere((key, value) => key == null || value == null);

    var new_details = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDatetime,
      'end_datetime_ms': endDatetime,
      'discipline_id': '$disciplineID',
      'settings': new_settings,
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
        'event_pos': LatLng(details['lat'], details['lon']),
        'is_participant': details['is_participating?'],
        'settings': details['settings'],
      };
    } else {
      throw Exception(
        'We cannot show you this event right now. Please try again later.',
      );
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
      throw Exception(json.decode(response.body)['message']);
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
        (event) => DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        ),
      );
    } else {
      throw Exception(
        'We cannot show your event list right now. Please try again later.',
      );
    }
  }

  List<EventPrivacyRule> getEventPrivacyRules() {
    var private = EventPrivacyRule(
      id: 1,
      name: 'Private',
      allowInvitations: false,
      requireParticipationAcceptation: true,
    );

    var public = EventPrivacyRule(
      id: 2,
      name: 'Public',
      allowInvitations: true,
      requireParticipationAcceptation: false,
    );

    var inviteOnly = EventPrivacyRule(
      id: 3,
      name: 'Invite Only',
      allowInvitations: true,
      requireParticipationAcceptation: true,
    );

    return [
      private,
      public,
      inviteOnly,
    ];
  }

  EventPrivacyRule convertSettingsToEventPrivacyRule(
      bool allowInvitations, bool requireParticipationAcceptation) {
    var eventPrivacySettings = getEventPrivacyRules();

    return eventPrivacySettings
        .where((a) => (a.allowInvitations == allowInvitations &&
            a.requireParticipationAcceptation ==
                requireParticipationAcceptation))
        .toList()
        .first;
  }

  Future<List<EventInvitation>> getEventInvitations() async {
    final client = AuthenticatedApiClient();
    final userRepository = UserRepository();
    final url = 'my_invitations';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      // ignore: omit_local_variable_types
      List<EventInvitation> eventInvitations = [];
      for (var invitation in json.decode(response.body)) {
        var eventDetails = await getEventDetails(invitation['event_id']);
        var inviter =
            await userRepository.getProfileDetails(invitation['inviter_id']);
        eventInvitations.add(EventInvitation(
          invitation['id'],
          invitation['invitee_id'],
          eventDetails,
          inviter,
        ));
      }
      return eventInvitations;
    } else {
      return [];
    }
  }

  void answerInvitation(EventInvitation eventInvitation, String answer) async {
    final client = AuthenticatedApiClient();
    final url = 'my_invitations/${eventInvitation.id}/${answer}';

    var response = await client.post(url);

    if (response.statusCode != 201) {
      throw Exception('Answering invitation failed! Please try again later.');
    }
  }
}

class Location extends Clusterable {
  final String id;
  final LatLng position;
  final String disciplineID;
  final BitmapDescriptor icon;

  Location({
    @required this.id,
    @required this.position,
    this.disciplineID,
    @required this.icon,
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

  Marker toMarker(Function zoomCluster) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      onTap: isCluster
          ? () => zoomCluster(clusterId)
          : () {
              showDialog(
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
                        color: Color(0xFFF3F3F3),
                        child: EventDetailsScrollable(eventID: id),
                      ),
                    ),
                  );
                },
              );
            },
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

class EventPrivacyRule {
  final int id;
  final String name;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  @override
  bool operator ==(dynamic other) =>
      other is EventPrivacyRule && id == other.id;

  @override
  int get hashCode => super.hashCode;

  EventPrivacyRule({
    this.id,
    this.name,
    this.allowInvitations,
    this.requireParticipationAcceptation,
  });
}

class Event {
  final String id;
  final String name;
  final String description;
  final String disciplineID;
  final LatLng pos;
  final DateTime startDate;
  final DateTime endDate;
  final List<dynamic> settings;
  Event(
    this.id,
    this.name,
    this.description,
    this.disciplineID,
    this.pos,
    this.startDate,
    this.endDate,
    this.settings,
  );

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['id'],
      json['name'],
      json['description'],
      json['discipline_id'],
      LatLng(json['lat'], json['lon']),
      DateTime.fromMillisecondsSinceEpoch(json['start_datetime_ms']),
      DateTime.fromMillisecondsSinceEpoch(json['end_datetime_ms']),
      json['settings'],
    );
  }
}

class EventInvitation {
  final String id;
  final String inviteeID;
  final Map<String, dynamic> eventDetails;
  final User inviter;

  EventInvitation(
    this.id,
    this.inviteeID,
    this.eventDetails,
    this.inviter,
  );
}

String getStaticEventLocationMapString(LatLng eventPos, int zoom) {
  return 'https://maps.googleapis.com/maps/api/staticmap?size=640x640&zoom=${zoom}&center=${eventPos.latitude},${eventPos.longitude}&markers=color:red|${eventPos.latitude},${eventPos.longitude}&key=AIzaSyBQ6O79g3WKA7Xjf3-Z1DnB4SuRZXbNrug';
}
