import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/userRepository.dart';

class EventInvitationEvent extends Equatable {
  const EventInvitationEvent();

  @override
  List<Object> get props => [];
}

class SearchRequested extends EventInvitationEvent {
  final String query;

  const SearchRequested({
    @required this.query,
  });

  @override
  List<Object> get props => [query];
}

class InviteButtonPressed extends EventInvitationEvent {
  final String eventID;
  final String inviteeID;
  final String query;
  final List<User> searchResults;

  const InviteButtonPressed({
    @required this.eventID,
    @required this.inviteeID,
    @required this.query,
    @required this.searchResults,
  });

  @override
  List<Object> get props => [eventID, inviteeID];
}
