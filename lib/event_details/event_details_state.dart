import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object> get props => [];
}

class EventDetailsUninitialized extends EventDetailsState {
  final String eventID;

  const EventDetailsUninitialized({@required this.eventID});
}

class EventDetailsLoading extends EventDetailsState {}

class EventDetailsUnjoined extends EventDetailsState {
  final String eventID;
  final Map<String, dynamic> eventDetails;
  final List<User> participantsList;
  final bool isOrganiser;

  const EventDetailsUnjoined({
    @required this.eventID,
    @required this.eventDetails,
    @required this.participantsList,
    @required this.isOrganiser,
  });
}

class EventDetailsJoined extends EventDetailsState {
  final String eventID;
  final Map<String, dynamic> eventDetails;
  final List<User> participantsList;
  final bool isOrganiser;

  const EventDetailsJoined({
    @required this.eventID,
    @required this.eventDetails,
    @required this.participantsList,
    @required this.isOrganiser,
  });
}

class EventDetailsRequested extends EventDetailsState {
  final String eventID;
  final Map<String, dynamic> eventDetails;
  final List<User> participantsList;
  final bool isOrganiser;

  const EventDetailsRequested({
    @required this.eventID,
    @required this.eventDetails,
    @required this.participantsList,
    @required this.isOrganiser,
  });
}

class EventDetailsFailure extends EventDetailsState {
  final String error;

  const EventDetailsFailure({@required this.error});
}
