import 'package:PickApp/repositories/group_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MyGroupsState extends Equatable {
  const MyGroupsState();

  @override
  List<Object> get props => [];
}

class MyGroupsUninitialized extends MyGroupsState {}

class MyGroupsLoading extends MyGroupsState {}

class MyGroupsReady extends MyGroupsState {
  final List<Group> myGroups;
  final List<GroupInvitation> groupInvitations;

  const MyGroupsReady({
    @required this.myGroups,
    @required this.groupInvitations,
  });

  @override
  List<Object> get props => [myGroups, groupInvitations];
}

class FetchGroupsFailure extends MyGroupsState {
  final String error;

  const FetchGroupsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class AnswerInvitationFailure extends MyGroupsState {
  final String error;

  const AnswerInvitationFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
