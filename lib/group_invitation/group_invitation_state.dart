import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class GroupInvitationState extends Equatable {
  const GroupInvitationState();

  @override
  List<Object> get props => [];
}

class GroupInvitationUninitialized extends GroupInvitationState {
  final String groupID;

  const GroupInvitationUninitialized({@required this.groupID});
}

class GroupInvitationSearchInProgress extends GroupInvitationState {
  final String query;

  const GroupInvitationSearchInProgress({@required this.query});

  @override
  List<Object> get props => [query];
}

class GroupInvitationSearchCompleted extends GroupInvitationState {
  final String query;
  final List<User> searchResult;

  const GroupInvitationSearchCompleted({
    @required this.query,
    @required this.searchResult,
  });

  @override
  List<Object> get props => [query, searchResult];
}

class GroupInvitationInvited extends GroupInvitationState {
  final String message;
  final String inviteeID;

  const GroupInvitationInvited({
    @required this.message,
    @required this.inviteeID,
  });

  @override
  List<Object> get props => [message, inviteeID];
}

class GroupInvitationFailure extends GroupInvitationState {
  final String error;

  const GroupInvitationFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
