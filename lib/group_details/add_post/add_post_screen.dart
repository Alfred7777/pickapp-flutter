import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_post_bloc.dart';
import 'add_post_state.dart';
import 'add_post_event.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/profile_picture_rounded.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class AddPostScreen extends StatefulWidget {
  final String groupID;

  AddPostScreen({@required this.groupID});

  @override
  State<AddPostScreen> createState() => AddPostScreenState(groupID: groupID);
}

class AddPostScreenState extends State<AddPostScreen> {
  final String groupID;
  final groupRepository = GroupRepository();
  final userRepository = UserRepository();
  AddPostBloc _addPostBloc;

  TextEditingController _contentTextController;

  AddPostScreenState({@required this.groupID});

  @override
  void initState() {
    super.initState();
    _addPostBloc = AddPostBloc(
      groupRepository: groupRepository,
      userRepository: userRepository,
      groupID: groupID,
    );
    _contentTextController = TextEditingController();
  }

  @override
  void dispose() {
    _contentTextController.dispose();
    _addPostBloc.close();
    super.dispose();
  }

  void _addPost() {
    if (_contentTextController.text.isNotEmpty) {
      _addPostBloc.add(
        AddPostButtonPressed(
          content: _contentTextController.text,
        ),
      );
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('You can\'t create empty post!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Add Post',
      ),
      body: SafeArea(
        child: BlocListener<AddPostBloc, AddPostState>(
          bloc: _addPostBloc,
          listener: (context, state) {
            if (state is AddPostFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is AddPostCreated) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder<AddPostBloc, AddPostState>(
            bloc: _addPostBloc,
            builder: (context, state) {
              if (state is AddPostUninitialized) {
                _addPostBloc.add(FetchAuthorProfile());
              }
              if (state is AddPostReady) {
                return AddPostScrollable(
                  contentController: _contentTextController,
                  author: state.author,
                  addPost: _addPost,
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

class AddPostScrollable extends StatelessWidget {
  final TextEditingController contentController;
  final User author;
  final Function addPost;

  const AddPostScrollable({
    @required this.contentController,
    @required this.author,
    @required this.addPost,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 1,
          expandedHeight: 56,
          backgroundColor: Colors.grey[100],
          forceElevated: true,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Row(
            children: [
              ProfilePicture(
                height: 44,
                width: 44,
                shape: BoxShape.circle,
                fit: BoxFit.fill,
                profilePictureUrl: author.profilePictureUrl,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Text(
                  author.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: addPost,
              elevation: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.transparent,
              child: Text(
                'PUBLISH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.04 * screenSize.width,
                ),
                child: TextFormField(
                  controller: contentController,
                  minLines: 1,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[400],
                    ),
                    hintText: 'What you want to tell your groupmates...',
                  ),
                  validator: (value) {
                    if (value.length > 500) {
                      return 'Group post can\'t be longer than 500 characters!';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
