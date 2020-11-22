import 'dart:async';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_invitation_bloc.dart';
import 'event_invitation_state.dart';
import 'event_invitation_event.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/repositories/userRepository.dart';

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
                  duration: Duration(milliseconds: 500),
                ),
              );
              _invitedUsers.add(state.inviteeID);
            }
            if (state is EventInvitationFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                  duration: Duration(milliseconds: 500),
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

class UserWidget extends StatelessWidget {
  final User user;
  final bool isInvited;
  final Function notifyParent;

  const UserWidget({
    @required this.user,
    @required this.isInvited,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        var route = MaterialPageRoute<void>(
          builder: (context) => ProfileScreen(
            userID: user.userID,
          ),
        );
        Navigator.push(context, route);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.01 * screenSize.width,
          horizontal: 0.04 * screenSize.width,
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 0.16 * screenSize.width,
                width: 0.16 * screenSize.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/profile_placeholder.png'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.04 * screenSize.width),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}',
                        style: TextStyle(
                          color: Color(0xFF3D3A3A),
                          fontSize: 0.05 * screenSize.width,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user.uniqueUsername}',
                        style: TextStyle(
                          color: Color(0xFFA7A7A7),
                          fontSize: 0.034 * screenSize.width,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () => isInvited ? {} : notifyParent(user.userID),
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
          ),
        ),
      ),
    );
  }
}

class SearchPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.search,
          size: 0.10 * screenSize.width,
          color: Colors.grey[200],
        ),
        Text(
          'Type to start searching',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 0.06 * screenSize.width,
          ),
        ),
      ],
    );
  }
}

class SearchLoading extends StatelessWidget {
  final String query;

  const SearchLoading({
    @required this.query,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
            top: 0.03 * screenSize.width,
          ),
          child: ShimmerUserLoading(
            height: 0.16 * screenSize.width,
            width: 0.9 * screenSize.width,
            time: 1400,
          ),
        );
      },
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
          return UserWidget(
            user: userList[index],
            isInvited: invitedUsers.contains(userList[index].userID),
            notifyParent: notifyParent,
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
