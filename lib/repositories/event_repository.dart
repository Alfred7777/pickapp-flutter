import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user_repository.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:PickApp/client.dart';
import 'package:PickApp/utils/string_formatter.dart';

class EventRepository {
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
      throw Exception('Failed to get event disciplines!');
    }
  }

  Future<String> createEvent({
    @required String name,
    @required String description,
    @required String disciplineID,
    @required LatLng pos,
    @required String locationID,
    @required DateTime startDate,
    @required DateTime endDate,
    @required bool allowInvitations,
    @required bool requireParticipationAcceptation,
    @required int recurrenceIntervalInSeconds,
  }) async {
    var client = AuthenticatedApiClient();

    var body = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDate.toUtc().millisecondsSinceEpoch,
      'end_datetime_ms': endDate.toUtc().millisecondsSinceEpoch,
      'lat': pos == null ? null : pos.latitude,
      'lon': pos == null ? null : pos.longitude,
      'location_id': '$locationID',
      'discipline_id': '$disciplineID',
      'settings': {
        'allow_invitations': allowInvitations,
        'require_participation_acceptation': requireParticipationAcceptation,
      },
      'recurrence_interval_in_seconds': recurrenceIntervalInSeconds,
    };

    body.removeWhere((key, value) {
      if (key == null || value == null || value == 'null') {
        return true;
      }
      return false;
    });

    var response = await client.post('events', body: body);
    if (response.statusCode == 201) {
      return 'Event successfully created.';
    } else {
      return StringFormatter.formatErrors(json.decode(response.body));
    }
  }

  Future<String> updateEvent({
    @required String eventID,
    @required String name,
    @required String description,
    @required String disciplineID,
    @required DateTime startDate,
    @required DateTime endDate,
    @required bool allowInvitations,
    @required bool requireParticipationAcceptation,
  }) async {
    var client = AuthenticatedApiClient();

    var new_settings;
    if (allowInvitations != null && requireParticipationAcceptation != null) {
      new_settings = {
        'allow_invitations': allowInvitations,
        'require_participation_acceptation': requireParticipationAcceptation,
      };
    }

    var new_details = {
      'name': '$name',
      'description': '$description',
      'start_datetime_ms': startDate?.toUtc()?.millisecondsSinceEpoch,
      'end_datetime_ms': endDate?.toUtc()?.millisecondsSinceEpoch,
      'discipline_id': '$disciplineID',
      'settings': new_settings,
    };

    new_details.removeWhere((key, value) {
      if (key == null || value == null || value == 'null') {
        return true;
      }
      return false;
    });

    var body = {
      'new_details': new_details,
    };

    var response = await client.post('events/$eventID/edit', body: body);
    if (response.statusCode == 201) {
      return 'Event successfully updated.';
    } else {
      return StringFormatter.formatErrors(json.decode(response.body));
    }
  }

  Future<EventDetails> getEventDetails(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID';
    var response = await client.get(url);

    if (response.statusCode == 200) {
      return EventDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'We can\'t show you this event right now. Please try again later.',
      );
    }
  }

  Future<List<User>> getEventParticipants(String eventID) async {
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

  Future<String> joinEvent(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participants';

    var response = await client.post(url, body: {});

    if (response.statusCode == 201) {
      return 'Successfully joined event.';
    } else {
      return json.decode(response.body)['message'];
    }
  }

  Future<String> leaveEvent(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participants';

    var response = await client.delete(url);

    if (response.statusCode == 201) {
      return 'Successfully left event.';
    } else {
      return json.decode(response.body)['message'];
    }
  }

  Future<String> cancelParticipationRequest(String eventID) async {
    final client = AuthenticatedApiClient();
    final url = 'events/$eventID/participation_request/cancel';

    var response = await client.delete(url);

    if (response.statusCode == 201) {
      return 'Successfully canceled participation request in event.';
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

  Future<List<Event>> getMyEvents(String eventsType) async {
    final client = AuthenticatedApiClient();

    final url = 'user_dashboard/${eventsType}_events';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Event>((event) => Event.fromJson(event))
          .toList();
    } else {
      throw Exception(
        'We can\'t show your event list right now. Please try again later.',
      );
    }
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
        var inviter = await userRepository.getProfileDetails(
          invitation['inviter_id'],
        );
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

  Future<List<ParticipationRequest>> getParticipationRequests(
      String eventID) async {
    final client = AuthenticatedApiClient();
    final userRepository = UserRepository();
    final url = 'events/${eventID}/participation_requests';

    var response = await client.get(url);

    if (response.statusCode == 200) {
      // ignore: omit_local_variable_types
      List<ParticipationRequest> participationRequests = [];
      for (var request in json.decode(response.body)) {
        var requester = await userRepository.getProfileDetails(
          request['requester_id'],
        );
        participationRequests.add(ParticipationRequest(
          request['event_id'],
          requester,
        ));
      }
      return participationRequests;
    } else {
      return [];
    }
  }

  void answerParticipationRequest(
      String eventID, String requesterID, String answer) async {
    final client = AuthenticatedApiClient();
    final url = 'events/${eventID}/participation_request/${answer}';
    final body = {
      'requester_id': '$requesterID',
    };

    var response = await client.post(url, body: body);

    if (response.statusCode != 201) {
      throw Exception(
        'Answering participation request failed! Please try again later.',
      );
    }
  }

  Future<List<Event>> searchEvent(String searchPhrase) async {
    final client = AuthenticatedApiClient();
    final url = 'events/search';
    var queryParams = {
      'phrase': searchPhrase,
    };

    var response = await client.get(url, queryParams: queryParams);

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map<Event>((event) => Event.fromJson(event))
          .toList();
    } else {
      throw Exception(
        'We can\'t show you search results right now. Please try again later.',
      );
    }
  }
}

class Discipline {
  final String id;
  final String name;

  Discipline(
    this.id,
    this.name,
  );

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      json['id'],
      json['name'],
    );
  }
}

class Event {
  final String id;
  final String name;
  final String disciplineID;
  final LatLng pos;
  final DateTime startDate;
  final DateTime endDate;

  const Event(
    this.id,
    this.name,
    this.disciplineID,
    this.pos,
    this.startDate,
    this.endDate,
  );

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['id'],
      json['name'],
      json['discipline_id'],
      LatLng(json['lat'], json['lon']),
      DateTime.fromMillisecondsSinceEpoch(json['start_datetime_ms']),
      DateTime.fromMillisecondsSinceEpoch(json['end_datetime_ms']),
    );
  }
}

class EventDetails {
  final String id;
  final String name;
  final String description;
  final String disciplineID;
  final String organiserProfilePictureUrl;
  final LatLng position;
  final DateTime startDate;
  final DateTime endDate;
  final String participationStatus;
  final bool isOrganiser;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;
  final int recurrenceIntervalInSeconds;

  EventDetails(
    this.id,
    this.name,
    this.description,
    this.disciplineID,
    this.organiserProfilePictureUrl,
    this.position,
    this.startDate,
    this.endDate,
    this.participationStatus,
    this.isOrganiser,
    this.allowInvitations,
    this.requireParticipationAcceptation,
    this.recurrenceIntervalInSeconds,
  );

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      json['id'],
      json['name'],
      json['description'],
      json['discipline_id'],
      json['organiser_profile_picture_url'],
      LatLng(json['lat'], json['lon']),
      DateTime.fromMillisecondsSinceEpoch(json['start_datetime_ms']),
      DateTime.fromMillisecondsSinceEpoch(json['end_datetime_ms']),
      json['participation']['status'],
      json['participation']['is_organiser?'],
      json['settings']['allow_invitations'],
      json['settings']['require_participation_acceptation'],
      json['recurrence_interval_in_seconds'],
    );
  }
}

class EventInvitation {
  final String id;
  final String inviteeID;
  final EventDetails eventDetails;
  final User inviter;

  EventInvitation(
    this.id,
    this.inviteeID,
    this.eventDetails,
    this.inviter,
  );
}

class ParticipationRequest {
  final String eventID;
  final User requester;

  ParticipationRequest(
    this.eventID,
    this.requester,
  );
}

class EventPrivacyRule {
  final String id;
  final String name;
  final String description;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  EventPrivacyRule(
    this.id,
    this.name,
    this.description,
    this.allowInvitations,
    this.requireParticipationAcceptation,
  );

  @override
  bool operator ==(dynamic other) =>
      other is EventPrivacyRule && id == other.id;

  @override
  int get hashCode => super.hashCode;

  static List<EventPrivacyRule> getEventPrivacyRules() {
    var private = EventPrivacyRule(
      '1',
      'Private',
      'Other users can\'t invite people to your event and you need to accept every participant.',
      false,
      true,
    );
    var public = EventPrivacyRule(
      '2',
      'Public',
      'Other users can invite people to your event and you don\'t need to accept event participants.',
      true,
      false,
    );
    var inviteOnly = EventPrivacyRule(
      '3',
      'Invite Only',
      'Other users can invite people to your event, but you need to accept every participant.',
      true,
      true,
    );

    return [
      private,
      public,
      inviteOnly,
    ];
  }

  factory EventPrivacyRule.fromBooleans(
    bool allowInvitations,
    bool requireParticipationAcceptation,
  ) {
    var _eventPrivacyRules = getEventPrivacyRules();
    if (!allowInvitations) {
      return _eventPrivacyRules[0];
    } else if (requireParticipationAcceptation) {
      return _eventPrivacyRules[2];
    } else {
      return _eventPrivacyRules[1];
    }
  }
}

class EventRecurringRule {
  final String id;
  final String name;
  final String description;
  final int recurrenceIntervalInSeconds;

  static final secondsInDay = 24 * 60 * 60;

  EventRecurringRule(
    this.id,
    this.name,
    this.description,
    this.recurrenceIntervalInSeconds,
  );

  @override
  bool operator ==(dynamic other) =>
      other is EventRecurringRule && id == other.id;

  @override
  int get hashCode => super.hashCode;

  static String getRuleName(int recurrenceIntervalInSeconds) {
    var availableRules = getEventRecurringRules();

    for (var i = 0; i < availableRules.length; i++) {
      if (availableRules[i].recurrenceIntervalInSeconds ==
          recurrenceIntervalInSeconds) {
        return availableRules[i].name;
      }
    }
    return availableRules[0].name;
  }

  static List<EventRecurringRule> getEventRecurringRules() {
    var none = EventRecurringRule('1', 'None', 'Event would not repeat', null);
    var daily = EventRecurringRule(
        '2', 'Daily', 'Event will repeat every day', secondsInDay);
    var weekly = EventRecurringRule(
        '3', 'Weekly', 'Event will repeat every week', 7 * secondsInDay);

    var monthly = EventRecurringRule(
        '4', 'Monthly', 'Event will repeat every month', 30 * secondsInDay);

    var yearly = EventRecurringRule(
        '5', 'Yearly', 'Event will repeat every year', 365 * secondsInDay);

    return [none, daily, weekly, monthly, yearly];
  }
}
