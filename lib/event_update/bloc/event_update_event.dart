import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class EventUpdateEvent extends Equatable {
  const EventUpdateEvent();

  @override
  List<Object> get props => [];
}

class EventUpdateFirstStepFinished extends EventUpdateEvent {
  final String eventName;
  final String eventDisciplineID;

  const EventUpdateFirstStepFinished({
    @required this.eventName,
    @required this.eventDisciplineID,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDisciplineID,
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

  UpdateEventButtonPressed({
    this.eventName,
    this.eventDescription,
    this.eventDisciplineID,
    this.eventID,
    this.eventStartDate,
    this.eventEndDate,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDescription,
        eventDisciplineID,
        eventID,
        eventStartDate,
        eventEndDate,
      ];
}
