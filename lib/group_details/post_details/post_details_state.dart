import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class PostDetailsState extends Equatable {
  const PostDetailsState();

  @override
  List<Object> get props => [];
}

class PostDetailsUninitialized extends PostDetailsState {
  final GroupPost groupPost;

  const PostDetailsUninitialized({@required this.groupPost});

  @override
  List<Object> get props => [groupPost];
}

class PostDetailsLoading extends PostDetailsState {}

class PostDetailsReady extends PostDetailsState {
  final GroupPost groupPost;
  final List<PostComment> postComments;
  final User userProfile;

  const PostDetailsReady({
    @required this.groupPost,
    @required this.postComments,
    @required this.userProfile,
  });

  @override
  List<Object> get props => [groupPost, postComments, userProfile];
}

class PostDetailsFailure extends PostDetailsState {
  final String error;

  const PostDetailsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
