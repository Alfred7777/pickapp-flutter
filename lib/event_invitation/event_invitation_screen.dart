import 'dart:async';
import 'package:PickApp/widgets/list_bar/user_bar.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/search/search_loading.dart';
import 'package:PickApp/widgets/search/search_placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_invitation_bloc.dart';
import 'event_invitation_state.dart';
import 'event_invitation_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventInvitationScreen extends StatefulWidget {
  final String eventID;

  EventInvitationScreen({@required this.eventID});

  @override
  State<EventInvitationScreen> createState() =>
      EventInvitationScreenState(eventID: eventID);
}

class EventInvitationScreenState extends State<EventInvitationScreen> {
  final String eventID;
  final eventRepository = EventRepository();
  final userRepository = UserRepository();
  EventInvitationBloc _eventInvitationBloc;

  TextEditingController _queryTextController;
  Timer _debounce;
  final int _debouncetime = 500;

  Set<String> _invitedUsers;

  EventInvitationScreenState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _eventInvitationBloc = EventInvitationBloc(
      eventRepository: eventRepository,
      userRepository: userRepository,
      eventID: eventID,
    );

    _queryTextController = TextEditingController();
    _queryTextController.addListener(onQueryChanged);

    _invitedUsers = {};
  }

  @override
  void dispose() {
    _queryTextController.removeListener(onQueryChanged);
    _queryTextController.dispose();
    _eventInvitationBloc.close();
    super.dispose();
  }

  void onQueryChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debouncetime), () {
      if (_queryTextController.text.isNotEmpty) {
        if (_eventInvitationBloc.state is EventInvitationUninitialized) {
          _eventInvitationBloc.add(
            SearchRequested(
              query: _queryTextController.text,
            ),
          );
        } else {
          if (_eventInvitationBloc.state.props.first !=
                  _queryTextController.text &&
              _eventInvitationBloc.state is! EventInvitationSearchInProgress) {
            _eventInvitationBloc.add(
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
    _eventInvitationBloc.add(
      InviteButtonPressed(
        eventID: eventID,
        inviteeID: userID,
        query: _queryTextController.text,
        searchResults: _eventInvitationBloc.state.props.last,
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
        child: BlocListener<EventInvitationBloc, EventInvitationState>(
          bloc: _eventInvitationBloc,
          listener: (context, state) {
            if (state is EventInvitationInvited) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.message}'),
                  backgroundColor: Colors.green,
                ),
              );
              _invitedUsers.add(state.inviteeID);
            }
            if (state is EventInvitationFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<EventInvitationBloc, EventInvitationState>(
            bloc: _eventInvitationBloc,
            condition: (prevState, currState) =>
                currState is! EventInvitationFailure &&
                currState is! EventInvitationInvited,
            builder: (context, state) {
              if (state is EventInvitationSearchInProgress) {
                return SearchLoading(query: state.query);
              }
              if (state is EventInvitationSearchCompleted) {
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
                height: 46,
                minWidth: 46,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  isInvited ? Icons.check : Icons.person_add,
                  size: 30,
                  color: Colors.lightBlue[300],
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
                  fontSize: 18,
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
