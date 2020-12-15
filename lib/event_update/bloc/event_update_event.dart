import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/event_repository.dart';

class EventUpdateEvent extends Equatable {
  const EventUpdateEvent();

  @override
  List<Object> get props => [];
}

class EventUpdateFirstStepFinished extends EventUpdateEvent {
  final String eventName;
  final String eventDisciplineID;
  final EventPrivacyRule eventPrivacy;

  const EventUpdateFirstStepFinished({
    @required this.eventName,
    @required this.eventDisciplineID,
    @required this.eventPrivacy,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDisciplineID,
        eventPrivacy,
      ];
}

// to allow empty values
// ignore: must_be_immutable
class UpdateEventButtonPressed extends EventUpdateEvent {
  String eventName;
  String eventDescription;
  String eventDisciplineID;
  String eventID;
  DateTime eventStartDate;
  DateTime eventEndDate;
  bool allowInvitations;
  bool requireParticipationAcceptation;

  UpdateEventButtonPressed({
    this.eventName,
    this.eventDescription,
    this.eventDisciplineID,
    this.eventID,
    this.eventStartDate,
    this.eventEndDate,
    this.allowInvitations,
    this.requireParticipationAcceptation,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDescription,
        eventDisciplineID,
        eventID,
        eventStartDate,
        eventEndDate,
        allowInvitations,
        requireParticipationAcceptation,
      ];
}
