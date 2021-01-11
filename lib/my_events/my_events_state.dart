import 'package:PickApp/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MyEventsState extends Equatable {
  const MyEventsState();

  @override
  List<Object> get props => [];
}

class MyEventsUninitialized extends MyEventsState {}

class MyEventsLoading extends MyEventsState {}

class MyEventsReady extends MyEventsState {
  final List<Event> myActiveEvents;
  final List<Event> myPastEvents;
  final List<EventInvitation> eventInvitations;

  const MyEventsReady({
    @required this.myActiveEvents,
    @required this.myPastEvents,
    @required this.eventInvitations,
  });

  @override
  List<Object> get props => [myActiveEvents, myPastEvents, eventInvitations];
}

class FetchEventsFailure extends MyEventsState {
  final String error;

  const FetchEventsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class AnswerInvitationFailure extends MyEventsState {
  final String error;

  const AnswerInvitationFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
