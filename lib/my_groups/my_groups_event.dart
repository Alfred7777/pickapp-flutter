import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/group_repository.dart';

class MyGroupsEvent extends Equatable {
  const MyGroupsEvent();

  @override
  List<Object> get props => [];
}

class FetchMyGroups extends MyGroupsEvent {}

class AnswerInvitation extends MyGroupsEvent {
  final GroupInvitation invitation;
  final List<Group> myGroups;
  final List<GroupInvitation> groupInvitations;
  final String answer;

  const AnswerInvitation({
    @required this.invitation,
    @required this.myGroups,
    @required this.groupInvitations,
    @required this.answer,
  });

  @override
  List<Object> get props => [
        invitation,
        myGroups,
        groupInvitations,
        answer,
      ];
}
