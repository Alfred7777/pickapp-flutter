import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/event_repository.dart';

class EventUpdateState extends Equatable {
  const EventUpdateState();

  @override
  List<Object> get props => [];
}

class EventUpdateUninitialized extends EventUpdateState {
  final String eventID;

  const EventUpdateUninitialized({
    @required this.eventID,
  });

  @override
  List<Object> get props => [eventID];
}

class EventUpdateLoading extends EventUpdateState {}

class EventUpdateReady extends EventUpdateState {
  final EventDetails initialDetails;
  final List<Discipline> disciplines;

  const EventUpdateReady({
    @required this.initialDetails,
    @required this.disciplines,
  });

  @override
  List<Object> get props => [initialDetails, disciplines];
}

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
