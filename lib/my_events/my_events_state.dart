import 'package:PickApp/repositories/eventRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MyEventsState extends Equatable {
  const MyEventsState();

  @override
  List<Object> get props => [];
}

class MyEventsUninitialized extends MyEventsState {}

class MyEventsReady extends MyEventsState {
  final Map<DateTime, List<Event>> myActiveEvents;
  final Map<DateTime, List<Event>> myPastEvents;

  const MyEventsReady({
    @required this.myActiveEvents,
    @required this.myPastEvents,
  });

  @override
  List<Object> get props => [myActiveEvents, myPastEvents];
}

class MyEventsFailure extends MyEventsState {
  final String error;

  const MyEventsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
