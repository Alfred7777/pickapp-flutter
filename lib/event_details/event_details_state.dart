import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/userRepository.dart';

class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object> get props => [];
}

class EventDetailsUninitialized extends EventDetailsState {
  final String eventID;

  const EventDetailsUninitialized({@required this.eventID});
}

class EventDetailsReady extends EventDetailsState {
  final String eventID;
  final Map<String, dynamic> eventDetails;
  final List<Profile> participantsList;

  const EventDetailsReady({
    @required this.eventID,
    @required this.eventDetails, 
    @required this.participantsList,
  });
}

class EventDetailsJoined extends EventDetailsState {
  final String eventID;
  final Map<String, dynamic> eventDetails;
  final List<Profile> participantsList;

  const EventDetailsJoined({
    @required this.eventID,
    @required this.eventDetails, 
    @required this.participantsList,
  });
}