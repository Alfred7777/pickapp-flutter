import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_details_bloc.dart';
import 'group_details_state.dart';
import 'group_details_event.dart';
import 'add_post/add_post_screen.dart';
import 'package:PickApp/group_invitation/group_invitation_screen.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:PickApp/widgets/list_bar/post_bar.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupID;

  GroupDetailsScreen({@required this.groupID});

  @override
  State<GroupDetailsScreen> createState() =>
      GroupDetailsScreenState(groupID: groupID);
}

class GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final String groupID;
  final groupRepository = GroupRepository();
  GroupDetailsBloc _groupDetailsBloc;

  GroupDetailsScreenState({@required this.groupID});

  @override
  void initState() {
    super.initState();
    _groupDetailsBloc = GroupDetailsBloc(
      groupRepository: groupRepository,
      groupID: groupID,
    );
  }

  @override
  void dispose() {
    _groupDetailsBloc.close();
    super.dispose();
  }

  void _addPost() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => AddPostScreen(groupID: groupID),
    );
    await Navigator.push(context, route);
    _groupDetailsBloc.add(FetchGroupDetails());
  }

  void _deleteGroup() async {
    var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteGroupDialog();
      },
    );
    if (response == 'yes') {
      _groupDetailsBloc.add(DeleteGroup());
    }
  }

  void _leaveGroup() async {
    var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LeaveGroupDialog();
      },
    );
    if (response == 'yes') {
      _groupDetailsBloc.add(LeaveGroup());
    }
  }

  void _inviteUser() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => GroupInvitationScreen(groupID: groupID),
    );
    await Navigator.push(context, route);
    _groupDetailsBloc.add(FetchGroupDetails());
  }

  void _removeUser(String userID) async {
    var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return RemoveUserDialog();
      },
    );
    if (response == 'yes') {
      _groupDetailsBloc.add(RemoveUser(userID));
    }
    _groupDetailsBloc.add(FetchGroupDetails());
  }

  Future<void> _refreshView() async {
    _groupDetailsBloc.add(FetchGroupDetails());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Group Details',
      ),
      body: SafeArea(
        child: BlocListener<GroupDetailsBloc, GroupDetailsState>(
          bloc: _groupDetailsBloc,
          listener: (context, state) {
            if (state is GroupDetailsFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is GroupDetailsGroupDeleted) {
              Navigator.pop(context);
            }
            if (state is GroupDetailsGroupLeft) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder<GroupDetailsBloc, GroupDetailsState>(
            bloc: _groupDetailsBloc,
            condition: (prevState, currState) {
              if (currState is GroupDetailsLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is GroupDetailsUninitialized) {
                _groupDetailsBloc.add(FetchGroupDetails());
              }
              if (state is GroupDetailsReady) {
                return GroupDetails(
                  groupDetails: state.groupDetails,
                  postList: state.postList,
                  memberList: state.memberList,
                  refreshView: _refreshView,
                  addPost: _addPost,
                  deleteGroup: _deleteGroup,
                  leaveGroup: _leaveGroup,
                  inviteUser: _inviteUser,
                  removeUser: _removeUser,
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

class DeleteGroupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm deletion'),
      content: Text('Do you want to delete this group?'),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop('yes');
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop('no');
          },
        ),
      ],
    );
  }
}

class LeaveGroupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm leaving'),
      content: Text('Do you want to leave this group?'),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop('yes');
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop('no');
          },
        ),
      ],
    );
  }
}

class RemoveUserDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm deletion'),
      content: Text('Do you want to remove this user from group?'),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop('yes');
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop('no');
          },
        ),
      ],
    );
  }
}

class GroupDetails extends StatelessWidget {
  final Group groupDetails;
  final List<GroupPost> postList;
  final List<User> memberList;
  final Function refreshView;
  final Function addPost;
  final Function deleteGroup;
  final Function leaveGroup;
  final Function inviteUser;
  final Function removeUser;

  const GroupDetails({
    @required this.groupDetails,
    @required this.postList,
    @required this.memberList,
    @required this.refreshView,
    @required this.deleteGroup,
    @required this.addPost,
    @required this.leaveGroup,
    @required this.inviteUser,
    @required this.removeUser,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: screenSize.width,
            color: Colors.grey[100],
            child: TabBar(
              labelColor: Colors.grey[700],
              labelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(
                  text: 'Posts',
                  icon: Icon(
                    Icons.article,
                  ),
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  text: 'Members',
                  icon: Icon(
                    Icons.group,
                  ),
                  iconMargin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: refreshView,
                  child: PostList(
                    groupDetails: groupDetails,
                    postList: postList,
                    addPost: addPost,
                    deleteGroup: deleteGroup,
                    leaveGroup: leaveGroup,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: refreshView,
                  child: MemberList(
                    ownerID: groupDetails.ownerID,
                    memberList: memberList,
                    inviteUser: inviteUser,
                    removeUser: removeUser,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final Group groupDetails;
  final List<GroupPost> postList;
  final Function addPost;
  final Function deleteGroup;
  final Function leaveGroup;

  const PostList({
    @required this.groupDetails,
    @required this.postList,
    @required this.addPost,
    @required this.deleteGroup,
    @required this.leaveGroup,
  });

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            groupDetails.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: groupDetails.isOwner ? deleteGroup : () {},
              elevation: 0,
              height: 40,
              minWidth: 40,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.transparent,
              shape: CircleBorder(),
              child: Icon(
                groupDetails.isOwner ? Icons.delete : Icons.exit_to_app,
                size: 28,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              AddPostBar(
                addPost: addPost,
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return PostBar(
                groupID: groupDetails.id,
                post: postList[index],
                redirectToDetails: true,
              );
            },
            childCount: postList.length,
          ),
        ),
      ],
    );
  }
}

class AddPostBar extends StatelessWidget {
  final Function addPost;

  const AddPostBar({
    @required this.addPost,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 12,
          ),
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
            onTap: addPost,
            child: Container(
              height: 36,
              width: 0.94 * screenSize.width,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[300],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                  ),
                  child: Text(
                    'Add post to group...',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MemberList extends StatelessWidget {
  final String ownerID;
  final List<User> memberList;
  final Function inviteUser;
  final Function removeUser;

  const MemberList({
    @required this.ownerID,
    @required this.memberList,
    @required this.inviteUser,
    @required this.removeUser,
  });

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'Members: ${memberList.length}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: inviteUser,
              elevation: 0,
              height: 40,
              minWidth: 40,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.transparent,
              shape: CircleBorder(),
              child: Icon(
                Icons.person_add,
                size: 28,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return UserBar(
                user: memberList[index],
                actionList: ownerID == memberList[index].userID
                    ? []
                    : [
                        // MaterialButton(
                        //   onPressed: () => removeUser(
                        //     memberList[index].userID,
                        //   ),
                        //   elevation: 0,
                        //   height: 42,
                        //   minWidth: 42,
                        //   materialTapTargetSize:
                        //       MaterialTapTargetSize.shrinkWrap,
                        //   color: Colors.transparent,
                        //   shape: CircleBorder(),
                        //   child: Icon(
                        //     Icons.clear,
                        //     size: 30,
                        //     color: Colors.red,
                        //   ),
                        // ),
                      ],
              );
            },
            childCount: memberList.length,
          ),
        ),
      ],
    );
  }
}
