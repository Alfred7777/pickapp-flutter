import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class EventDetailsEvent extends Equatable {
  const EventDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchEventDetails extends EventDetailsEvent {
  final String eventID;

  FetchEventDetails({@required this.eventID});

  @override
  List<Object> get props => [eventID];
}

class JoinEvent extends EventDetailsEvent {
  final String eventID;

  JoinEvent({@required this.eventID});

  @override
  List<Object> get props => [eventID];
}
