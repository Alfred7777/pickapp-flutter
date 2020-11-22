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

class EventInvitationSearchInProgress extends EventInvitationState {
  final String query;

  const EventInvitationSearchInProgress({@required this.query});

  @override
  List<Object> get props => [query];
}

class EventInvitationSearchCompleted extends EventInvitationState {
  final String query;
  final List<User> searchResult;

  const EventInvitationSearchCompleted({
    @required this.query,
    @required this.searchResult,
  });

  @override
  List<Object> get props => [query, searchResult];
}

class EventInvitationInvited extends EventInvitationState {
  final String message;
  final String inviteeID;

  const EventInvitationInvited({
    @required this.message,
    @required this.inviteeID,
  });

  @override
  List<Object> get props => [message, inviteeID];
}

class EventInvitationFailure extends EventInvitationState {
  final String error;

  const EventInvitationFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
