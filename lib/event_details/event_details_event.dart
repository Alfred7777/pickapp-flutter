import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class EventDetailsEvent extends Equatable {
  final String eventID;

  const EventDetailsEvent({@required this.eventID});

  @override
  List<Object> get props => [eventID];
}

class FetchEventDetails extends EventDetailsEvent {
  FetchEventDetails(String eventID) : super(eventID: eventID);

  @override
  List<Object> get props => [eventID];
}

class JoinEvent extends EventDetailsEvent {
  JoinEvent(String eventID) : super(eventID: eventID);

  @override
  List<Object> get props => [eventID];
}

class LeaveEvent extends EventDetailsEvent {
  LeaveEvent(String eventID) : super(eventID: eventID);

  @override
  List<Object> get props => [eventID];
}
