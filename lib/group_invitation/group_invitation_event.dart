import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class GroupInvitationEvent extends Equatable {
  const GroupInvitationEvent();

  @override
  List<Object> get props => [];
}

class SearchRequested extends GroupInvitationEvent {
  final String query;

  const SearchRequested({
    @required this.query,
  });

  @override
  List<Object> get props => [query];
}

class InviteButtonPressed extends GroupInvitationEvent {
  final String groupID;
  final String inviteeID;
  final String query;
  final List<User> searchResults;

  const InviteButtonPressed({
    @required this.groupID,
    @required this.inviteeID,
    @required this.query,
    @required this.searchResults,
  });

  @override
  List<Object> get props => [groupID, inviteeID, query, searchResults];
}
