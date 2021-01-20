import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'group_details_event.dart';
import 'group_details_state.dart';
import 'package:PickApp/repositories/group_repository.dart';

class GroupDetailsBloc extends Bloc<GroupDetailsEvent, GroupDetailsState> {
  final GroupRepository groupRepository;
  final String groupID;

  GroupDetailsBloc({
    @required this.groupRepository,
    @required this.groupID,
  });

  @override
  GroupDetailsState get initialState => GroupDetailsUninitialized(
        groupID: groupID,
      );

  @override
  Stream<GroupDetailsState> mapEventToState(GroupDetailsEvent event) async* {
    if (event is FetchGroupDetails) {
      try {
        yield GroupDetailsLoading();

        var _members = await groupRepository.getGroupMembers(groupID);
        var _groupDetails = await groupRepository.getGroupDetails(groupID);
        var _posts = await groupRepository.getGroupPosts(groupID);

        yield GroupDetailsReady(
          groupID: groupID,
          groupDetails: _groupDetails,
          postList: _posts,
          memberList: _members,
        );
      } catch (exception) {
        yield GroupDetailsFailure(error: exception.message);
      }
    }
    if (event is RemoveUser) {
      try {
        await groupRepository.removeUser(
          event.userID,
          groupID,
        );
      } catch (exception) {
        yield GroupDetailsFailure(error: exception.message);
      }
    }
    if (event is DeleteGroup) {
      try {
        await groupRepository.deleteGroup(groupID);

        yield GroupDetailsGroupDeleted();
      } catch (exception) {
        yield GroupDetailsFailure(error: exception.message);
      }
    }
    if (event is LeaveGroup) {
      try {
        await groupRepository.removeUser(
          null,
          groupID,
        );
        yield GroupDetailsGroupLeft();
      } catch (exception) {
        yield GroupDetailsFailure(error: exception.message);
      }
    }
  }
}
