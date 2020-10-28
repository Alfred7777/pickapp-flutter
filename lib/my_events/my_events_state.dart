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
  final Map<DateTime, List<Event>> myEvents;

  const MyEventsReady({@required this.myEvents});

  @override
  List<Object> get props => [myEvents];
}
