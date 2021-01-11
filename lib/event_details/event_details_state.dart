import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/repositories/event_repository.dart';

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

class EventDetailsReady extends EventDetailsState {
  final String eventID;
  final EventDetails eventDetails;
  final List<User> participantsList;

  const EventDetailsReady({
    @required this.eventID,
    @required this.eventDetails,
    @required this.participantsList,
  });
}

class EventDetailsFailure extends EventDetailsState {
  final String error;

  const EventDetailsFailure({@required this.error});
}
