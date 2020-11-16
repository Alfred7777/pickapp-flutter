import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class EventInvitationEvent extends Equatable {
  const EventInvitationEvent();

  @override
  List<Object> get props => [];
}

class SearchButtonPressed extends EventInvitationEvent {
  final String searchPhrase;

  const SearchButtonPressed({
    @required this.searchPhrase,
  });

  @override
  List<Object> get props => [searchPhrase];
}

class InviteButtonPressed extends EventInvitationEvent {
  final String eventID;
  final String inviteeID;

  const InviteButtonPressed({
    @required this.eventID,
    @required this.inviteeID,
  });

  @override
  List<Object> get props => [eventID, inviteeID];
}