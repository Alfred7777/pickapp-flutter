import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/event_repository.dart';

class EventUpdateEvent extends Equatable {
  const EventUpdateEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialDetails extends EventUpdateEvent {
  final String eventID;

  const FetchInitialDetails({
    @required this.eventID,
  });

  @override
  List<Object> get props => [eventID];
}

class NextStepButtonPressed extends EventUpdateEvent {
  final EventDetails initialDetails;

  const NextStepButtonPressed({
    @required this.initialDetails,
  });

  @override
  List<Object> get props => [initialDetails];
}

class UpdateEventButtonPressed extends EventUpdateEvent {
  final EventDetails initialDetails;
  final List<Discipline> disciplines;
  final String eventID;
  final String eventName;
  final String eventDescription;
  final String eventDisciplineID;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final EventPrivacyRule eventPrivacyRule;

  UpdateEventButtonPressed({
    @required this.initialDetails,
    @required this.disciplines,
    @required this.eventID,
    @required this.eventName,
    @required this.eventDescription,
    @required this.eventDisciplineID,
    @required this.eventStartDate,
    @required this.eventEndDate,
    @required this.eventPrivacyRule,
  });

  @override
  List<Object> get props => [
        initialDetails,
        disciplines,
        eventID,
        eventName,
        eventDescription,
        eventDisciplineID,
        eventStartDate,
        eventEndDate,
        eventPrivacyRule,
      ];
}
