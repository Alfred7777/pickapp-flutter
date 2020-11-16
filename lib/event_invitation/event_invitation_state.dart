import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/userRepository.dart';

class EventInvitationState extends Equatable {
  const EventInvitationState();

  @override
  List<Object> get props => [];
}

class EventInvitationUninitialized extends EventInvitationState {
  final String eventID;

  const EventInvitationUninitialized({@required this.eventID});
}

class EventInvitationSearchPerformed extends EventInvitationState {
  final List<User> searchResult;

  const EventInvitationSearchPerformed({@required this.searchResult});
}

class EventInvitationInvited extends EventInvitationState {
  final String message;

  const EventInvitationInvited({@required this.message});

  @override
  List<Object> get props => [message];
}

class EventInvitationFailure extends EventInvitationState {
  final String error;

  const EventInvitationFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
