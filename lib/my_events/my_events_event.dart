import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/event_repository.dart';

class MyEventsEvent extends Equatable {
  const MyEventsEvent();

  @override
  List<Object> get props => [];
}

class FetchMyEvents extends MyEventsEvent {}

class AnswerInvitation extends MyEventsEvent {
  final EventInvitation invitation;
  final Map<DateTime, List<Event>> myActiveEvents;
  final Map<DateTime, List<Event>> myPastEvents;
  final List<EventInvitation> eventInvitations;
  final String answer;

  const AnswerInvitation({
    @required this.invitation,
    @required this.myActiveEvents,
    @required this.myPastEvents,
    @required this.eventInvitations,
    @required this.answer,
  });

  @override
  List<Object> get props => [
        invitation,
        myActiveEvents,
        myPastEvents,
        eventInvitations,
        answer,
      ];
}
