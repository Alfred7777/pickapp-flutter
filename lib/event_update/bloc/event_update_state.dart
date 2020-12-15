import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/event_repository.dart';

class EventUpdateState extends Equatable {
  const EventUpdateState();

  @override
  List<Object> get props => [];
}

class EventUpdateInitial extends EventUpdateState {
  final String eventName;
  final String eventDisciplineID;
  final String eventDescription;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  const EventUpdateInitial({
    @required this.eventName,
    @required this.eventDisciplineID,
    @required this.eventDescription,
    @required this.eventStartDate,
    @required this.eventEndDate,
    @required this.allowInvitations,
    @required this.requireParticipationAcceptation,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDisciplineID,
        eventDescription,
        eventStartDate,
        eventEndDate,
        allowInvitations,
        requireParticipationAcceptation
      ];
}

class EventUpdateFirstStepSet extends EventUpdateState {
  final String eventName;
  final String eventDisciplineID;
  final EventPrivacyRule eventPrivacy;

  const EventUpdateFirstStepSet(
      {this.eventName, this.eventDisciplineID, this.eventPrivacy});

  @override
  List<Object> get props => [eventName, eventDisciplineID, eventPrivacy];
}

class EventUpdateLoading extends EventUpdateState {}

class EventUpdateSuccess extends EventUpdateState {
  final String message;

  const EventUpdateSuccess({@required this.message});

  @override
  List<Object> get props => [message];
}

class EventUpdateFailure extends EventUpdateState {
  final String error;

  const EventUpdateFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
