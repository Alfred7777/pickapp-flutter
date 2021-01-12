import 'package:PickApp/create_group/create_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_groups_bloc.dart';
import 'my_groups_state.dart';
import 'my_groups_event.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/list_bar/group_bar.dart';
import 'package:PickApp/widgets/list_bar/group_invitation_bar.dart';
import 'package:PickApp/repositories/group_repository.dart';

class MyGroupsScreen extends StatefulWidget {
  MyGroupsScreen();

  @override
  State<MyGroupsScreen> createState() => MyGroupsScreenState();
}

class MyGroupsScreenState extends State<MyGroupsScreen> {
  final groupRepository = GroupRepository();
  MyGroupsBloc _myGroupsBloc;

  @override
  void initState() {
    super.initState();
    _myGroupsBloc = MyGroupsBloc(groupRepository: groupRepository);
  }

  @override
  void dispose() {
    _myGroupsBloc.close();
    super.dispose();
  }

  void _answerInvitation(GroupInvitation groupInvitation, String answer) {
    if (answer == 'Accept') {
      _myGroupsBloc.add(
        AnswerInvitation(
          invitation: groupInvitation,
          myGroups: _myGroupsBloc.state.props.first,
          groupInvitations: _myGroupsBloc.state.props.last,
          answer: 'accept',
        ),
      );
    } else {
      _myGroupsBloc.add(
        AnswerInvitation(
          invitation: groupInvitation,
          myGroups: _myGroupsBloc.state.props.first,
          groupInvitations: _myGroupsBloc.state.props.last,
          answer: 'reject',
        ),
      );
    }
    Navigator.pop(context);
    _myGroupsBloc.add(FetchMyGroups());
  }

  void _navigateToCreateGroup() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(),
      ),
    );
    if (result != null) {
      _myGroupsBloc.add(FetchMyGroups());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('${result[0]}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _refreshView() async {
    _myGroupsBloc.add(FetchMyGroups());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyGroupsBloc, MyGroupsState>(
      bloc: _myGroupsBloc,
      listener: (context, state) {
        if (state is FetchGroupsFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is AnswerInvitationFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<MyGroupsBloc, MyGroupsState>(
        bloc: _myGroupsBloc,
        condition: (prevState, currState) {
          if (currState is AnswerInvitationFailure) {
            return false;
          }
          if (prevState is MyGroupsReady || currState is MyGroupsLoading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is MyGroupsUninitialized) {
            _myGroupsBloc.add(FetchMyGroups());
          }
          if (state is MyGroupsReady) {
            return MyGroups(
              groups: state.myGroups,
              groupInvitations: state.groupInvitations,
              refreshView: _refreshView,
              createGroup: _navigateToCreateGroup,
              answerInvitation: _answerInvitation,
            );
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class MyGroups extends StatelessWidget {
  final List<Group> groups;
  final List<GroupInvitation> groupInvitations;
  final Function refreshView;
  final Function createGroup;
  final Function answerInvitation;

  const MyGroups({
    @required this.groups,
    @required this.groupInvitations,
    @required this.refreshView,
    @required this.createGroup,
    @required this.answerInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: mainScreenTopBar(context),
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          onPressed: createGroup,
          backgroundColor: Colors.green,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 0.15 * screenSize.width,
                width: screenSize.width,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black45, width: 0.3),
                  ),
                ),
                child: TabBar(
                  labelColor: Colors.grey[700],
                  labelStyle: TextStyle(
                    fontSize: 0.04 * screenSize.width,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 0.04 * screenSize.width,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: [
                    Tab(
                      text: 'Invites',
                      icon: Icon(
                        Icons.mail_outline,
                      ),
                      iconMargin: EdgeInsets.zero,
                    ),
                    Tab(
                      text: 'Groups',
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
                      child: GroupInvitationList(
                        groupInvitations: groupInvitations,
                        answerInvitation: answerInvitation,
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: refreshView,
                      child: GroupList(
                        groups: groups,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupInvitationList extends StatelessWidget {
  final List<GroupInvitation> groupInvitations;
  final Function answerInvitation;

  const GroupInvitationList({
    @required this.groupInvitations,
    @required this.answerInvitation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: groupInvitations.length,
      itemBuilder: (BuildContext context, int index) {
        return GroupInvitationBar(
          groupInvitation: groupInvitations[index],
          answerInvitation: answerInvitation,
        );
      },
    );
  }
}

class GroupList extends StatelessWidget {
  final List<Group> groups;

  const GroupList({
    @required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        return GroupBar(
          group: groups[index],
        );
      },
    );
  }
}
