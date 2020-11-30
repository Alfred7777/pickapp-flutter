import 'package:PickApp/repositories/eventRepository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends CreateEventEvent {}

class LocationPicked extends CreateEventEvent {
  final List<Discipline> disciplines;
  final List<EventPrivacyRule> eventPrivacySettings;
  final LatLng pickedPos;

  const LocationPicked({
    @required this.disciplines,
    @required this.eventPrivacySettings,
    @required this.pickedPos,
  });

  @override
  List<Object> get props => [disciplines, pickedPos];
}

class CreateEventButtonPressed extends CreateEventEvent {
  final List<Discipline> disciplines;
  final List<EventPrivacyRule> eventPrivacySettings;

  final String eventName;
  final String eventDescription;
  final String eventDisciplineID;
  final LatLng eventPos;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  const CreateEventButtonPressed({
    @required this.disciplines,
    @required this.eventPrivacySettings,
    @required this.eventName,
    @required this.eventDescription,
    @required this.eventDisciplineID,
    @required this.eventPos,
    @required this.eventStartDate,
    @required this.eventEndDate,
    @required this.allowInvitations,
    @required this.requireParticipationAcceptation,
  });

  @override
  List<Object> get props => [
        disciplines,
        eventPrivacySettings,
        eventName,
        eventDescription,
        eventDisciplineID,
        eventPos,
        eventStartDate,
        eventEndDate,
        allowInvitations,
        requireParticipationAcceptation,
      ];
}
