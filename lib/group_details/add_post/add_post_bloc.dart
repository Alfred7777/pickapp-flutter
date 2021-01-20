import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'add_post_event.dart';
import 'add_post_state.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class AddPostBloc extends Bloc<AddPostEvent, AddPostState> {
  final GroupRepository groupRepository;
  final UserRepository userRepository;
  final String groupID;

  AddPostBloc({
    @required this.groupRepository,
    @required this.userRepository,
    @required this.groupID,
  });

  @override
  AddPostState get initialState => AddPostUninitialized(
        groupID: groupID,
      );

  @override
  Stream<AddPostState> mapEventToState(AddPostEvent event) async* {
    if (event is FetchAuthorProfile) {
      try {
        var _authorProfile = await userRepository.getProfileDetails(null);

        yield AddPostReady(
          groupID: groupID,
          author: _authorProfile,
        );
      } catch (exception) {
        yield AddPostFailure(error: exception.message);
      }
    }
    if (event is AddPostButtonPressed) {
      try {
        var _response = await groupRepository.addGroupPost(
          groupID,
          event.content,
        );

        yield AddPostCreated(message: _response);
      } catch (exception) {
        yield AddPostFailure(error: exception.message);
      }
    }
  }
}
