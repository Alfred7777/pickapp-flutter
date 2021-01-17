import 'package:PickApp/repositories/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateEventFormEvent extends Equatable {
  const CreateEventFormEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends CreateEventFormEvent {}

class CreateEventButtonPressed extends CreateEventFormEvent {
  final List<Discipline> disciplines;

  final String eventName;
  final String eventDescription;
  final String eventDisciplineID;
  final LatLng eventPos;
  final String locationID;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  const CreateEventButtonPressed({
    @required this.disciplines,
    @required this.eventName,
    @required this.eventDescription,
    @required this.eventDisciplineID,
    @required this.eventPos,
    @required this.locationID,
    @required this.eventStartDate,
    @required this.eventEndDate,
    @required this.allowInvitations,
    @required this.requireParticipationAcceptation,
  });

  @override
  List<Object> get props => [
        disciplines,
        eventName,
        eventDescription,
        eventDisciplineID,
        eventPos,
        locationID,
        eventStartDate,
        eventEndDate,
        allowInvitations,
        requireParticipationAcceptation,
      ];
}
