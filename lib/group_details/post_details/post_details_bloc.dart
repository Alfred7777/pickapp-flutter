import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'post_details_event.dart';
import 'post_details_state.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final GroupRepository groupRepository;
  final UserRepository userRepository;
  final String groupID;
  final GroupPost groupPost;

  PostDetailsBloc({
    @required this.groupRepository,
    @required this.userRepository,
    @required this.groupID,
    @required this.groupPost,
  });

  @override
  PostDetailsState get initialState => PostDetailsUninitialized(
        groupPost: groupPost,
      );

  @override
  Stream<PostDetailsState> mapEventToState(PostDetailsEvent event) async* {
    try {
      yield PostDetailsLoading();

      if (event is AddAnswerButtonPressed) {
        await groupRepository.addPostAnswer(
          groupID,
          groupPost.id,
          event.content,
        );
      }

      var _postComments = await groupRepository.getPostComments(
        groupID,
        groupPost.id,
      );
      var _userProfile = await userRepository.getProfileDetails(null);

      yield PostDetailsReady(
        groupPost: groupPost,
        postComments: _postComments,
        userProfile: _userProfile,
      );
    } catch (exception) {
      yield PostDetailsFailure(error: exception.message);
    }
  }
}
