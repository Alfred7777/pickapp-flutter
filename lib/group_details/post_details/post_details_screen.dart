import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_details_bloc.dart';
import 'post_details_state.dart';
import 'post_details_event.dart';
import 'package:PickApp/widgets/list_bar/post_bar.dart';
import 'package:PickApp/widgets/list_bar/post_comment_bar.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class PostDetailsScreen extends StatefulWidget {
  final String groupID;
  final GroupPost groupPost;

  PostDetailsScreen({
    @required this.groupID,
    @required this.groupPost,
  });

  @override
  State<PostDetailsScreen> createState() => PostDetailsScreenState(
        groupID: groupID,
        groupPost: groupPost,
      );
}

class PostDetailsScreenState extends State<PostDetailsScreen> {
  final String groupID;
  final GroupPost groupPost;
  final groupRepository = GroupRepository();
  final userRepository = UserRepository();
  PostDetailsBloc _postDetailsBloc;

  TextEditingController _commentTextController;

  PostDetailsScreenState({
    @required this.groupID,
    @required this.groupPost,
  });

  @override
  void initState() {
    super.initState();
    _postDetailsBloc = PostDetailsBloc(
      groupID: groupID,
      groupRepository: groupRepository,
      userRepository: userRepository,
      groupPost: groupPost,
    );
    _commentTextController = TextEditingController();
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _postDetailsBloc.close();
    super.dispose();
  }

  void _addComment() {
    if (_commentTextController.text.isNotEmpty) {
      _postDetailsBloc.add(
        AddAnswerButtonPressed(
          content: _commentTextController.text,
        ),
      );
      _commentTextController.clear();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('You can\'t post empty answer!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Post Details',
      ),
      body: SafeArea(
        child: BlocListener<PostDetailsBloc, PostDetailsState>(
          bloc: _postDetailsBloc,
          listener: (context, state) {
            if (state is PostDetailsFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<PostDetailsBloc, PostDetailsState>(
            bloc: _postDetailsBloc,
            condition: (prevState, currState) {
              if (currState is PostDetailsFailure) {
                return false;
              }
              if (currState is PostDetailsLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is PostDetailsUninitialized) {
                _postDetailsBloc.add(FetchPostAnswers(postID: groupPost.id));
              }
              if (state is PostDetailsReady) {
                return PostDetailsScrollable(
                  groupID: groupID,
                  groupPost: state.groupPost,
                  postComments: state.postComments,
                  userProfile: state.userProfile,
                  commentController: _commentTextController,
                  addComment: _addComment,
                );
              }
              return LoadingScreen();
            },
          ),
        ),
      ),
    );
  }
}

class PostDetailsScrollable extends StatelessWidget {
  final String groupID;
  final GroupPost groupPost;
  final List<PostComment> postComments;
  final User userProfile;
  final TextEditingController commentController;
  final Function addComment;

  const PostDetailsScrollable({
    @required this.groupID,
    @required this.groupPost,
    @required this.postComments,
    @required this.userProfile,
    @required this.commentController,
    @required this.addComment,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        PostBar(
          groupID: groupID,
          post: groupPost,
          redirectToDetails: false,
        ),
        AddCommentBar(
          userProfile: userProfile,
          commentController: commentController,
          addComment: addComment,
        ),
        CommentList(
          postComments: postComments,
        ),
      ],
    );
  }
}

class AddCommentBar extends StatelessWidget {
  final User userProfile;
  final TextEditingController commentController;
  final Function addComment;

  const AddCommentBar({
    @required this.userProfile,
    @required this.commentController,
    @required this.addComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 8,
            ),
            child: ProfilePicture(
              height: 44,
              width: 44,
              shape: BoxShape.circle,
              fit: BoxFit.fill,
              profilePictureUrl: userProfile.profilePictureUrl,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[300],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: TextField(
                  controller: commentController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[400],
                    ),
                    hintText: 'Post reply...',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 3,
            ),
            child: MaterialButton(
              onPressed: addComment,
              padding: EdgeInsets.zero,
              elevation: 0,
              height: 44,
              minWidth: 44,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.transparent,
              shape: CircleBorder(),
              child: Icon(
                Icons.send,
                size: 28,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final List<PostComment> postComments;

  const CommentList({
    @required this.postComments,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: postComments.length,
      itemBuilder: (BuildContext context, int index) {
        return PostCommentBar(
          comment: postComments[index],
        );
      },
    );
  }
}
