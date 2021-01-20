import 'dart:async';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/search/search_loading.dart';
import 'package:PickApp/widgets/search/search_placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_invitation_bloc.dart';
import 'group_invitation_state.dart';
import 'group_invitation_event.dart';
import 'package:PickApp/repositories/group_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class GroupInvitationScreen extends StatefulWidget {
  final String groupID;

  GroupInvitationScreen({@required this.groupID});

  @override
  State<GroupInvitationScreen> createState() =>
      GroupInvitationScreenState(groupID: groupID);
}

class GroupInvitationScreenState extends State<GroupInvitationScreen> {
  final String groupID;
  final groupRepository = GroupRepository();
  final userRepository = UserRepository();
  GroupInvitationBloc _groupInvitationBloc;

  TextEditingController _queryTextController;
  Timer _debounce;
  final int _debouncetime = 500;

  Set<String> _invitedUsers;

  GroupInvitationScreenState({@required this.groupID});

  @override
  void initState() {
    super.initState();
    _groupInvitationBloc = GroupInvitationBloc(
      groupRepository: groupRepository,
      userRepository: userRepository,
      groupID: groupID,
    );

    _queryTextController = TextEditingController();
    _queryTextController.addListener(onQueryChanged);

    _invitedUsers = {};
  }

  @override
  void dispose() {
    _queryTextController.removeListener(onQueryChanged);
    _queryTextController.dispose();
    _groupInvitationBloc.close();
    super.dispose();
  }

  void onQueryChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debouncetime), () {
      if (_queryTextController.text.isNotEmpty) {
        if (_groupInvitationBloc.state is GroupInvitationUninitialized) {
          _groupInvitationBloc.add(
            SearchRequested(
              query: _queryTextController.text,
            ),
          );
        } else {
          if (_groupInvitationBloc.state.props.first !=
                  _queryTextController.text &&
              _groupInvitationBloc.state is! GroupInvitationSearchInProgress) {
            _groupInvitationBloc.add(
              SearchRequested(
                query: _queryTextController.text,
              ),
            );
          }
        }
      }
    });
  }

  void inviteUser(String userID) {
    _groupInvitationBloc.add(
      InviteButtonPressed(
        groupID: groupID,
        inviteeID: userID,
        query: _queryTextController.text,
        searchResults: _groupInvitationBloc.state.props.last,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchTopBar(
        queryTextController: _queryTextController,
        searchFieldHint: 'Search for users',
        elevation: 1,
      ),
      body: SafeArea(
        child: BlocListener<GroupInvitationBloc, GroupInvitationState>(
          bloc: _groupInvitationBloc,
          listener: (context, state) {
            if (state is GroupInvitationInvited) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.message}'),
                  backgroundColor: Colors.green,
                ),
              );
              _invitedUsers.add(state.inviteeID);
            }
            if (state is GroupInvitationFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<GroupInvitationBloc, GroupInvitationState>(
            bloc: _groupInvitationBloc,
            condition: (prevState, currState) =>
                currState is! GroupInvitationFailure &&
                currState is! GroupInvitationInvited,
            builder: (context, state) {
              if (state is GroupInvitationSearchInProgress) {
                return SearchLoading(query: state.query);
              }
              if (state is GroupInvitationSearchCompleted) {
                return SearchResults(
                  query: state.query,
                  userList: state.searchResult,
                  invitedUsers: _invitedUsers,
                  notifyParent: inviteUser,
                );
              }
              return SearchPlaceholder();
            },
          ),
        ),
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  final List<User> userList;
  final Set<String> invitedUsers;
  final Function notifyParent;

  const SearchResults({
    @required this.query,
    @required this.userList,
    @required this.invitedUsers,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (userList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) {
          var isInvited = invitedUsers.contains(userList[index].userID);
          return UserBar(
            user: userList[index],
            actionList: [
              MaterialButton(
                onPressed: () =>
                    isInvited ? {} : notifyParent(userList[index].userID),
                elevation: 0,
                height: 0.13 * screenSize.width,
                minWidth: 0.13 * screenSize.width,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  isInvited ? Icons.check : Icons.person_add,
                  size: 0.08 * screenSize.width,
                  color: Color(0xFF7FBCF1),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Container(
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 0.02 * screenSize.width,
                right: 0.02 * screenSize.width,
                top: 0.06 * screenSize.width,
                bottom: 0.05 * screenSize.width,
              ),
              child: Text(
                'No results found for: \"$query\"',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 0.05 * screenSize.width,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}
