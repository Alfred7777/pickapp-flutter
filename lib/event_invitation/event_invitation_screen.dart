import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_invitation_bloc.dart';
import 'event_invitation_state.dart';
import 'event_invitation_event.dart';
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

  EventInvitationScreenState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _eventInvitationBloc = EventInvitationBloc(
        eventRepository: eventRepository,
        userRepository: userRepository,
        eventID: eventID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
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
                currState is! EventInvitationFailure,
            builder: (context, state) {
              if (state is EventInvitationSearchPerformed) {
                return _buildEventInvitation(eventID, state.searchResult);
              }
              return _buildEventInvitation(eventID);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventInvitation(String eventID, [List<User> userList]) {
    var screenSize = MediaQuery.of(context).size;
    final _searchFieldController = TextEditingController();
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 50.0,
              width: screenSize.width - 50,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF7FBCF1),
                    width: 2,
                  ),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for user you want to invite',
                  hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                  contentPadding: EdgeInsets.only(left: 12.0),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
                controller: _searchFieldController,
              ),
            ),
            ButtonTheme(
              height: 50,
              minWidth: 50,
              child: MaterialButton(
                onPressed: () {
                  _eventInvitationBloc.add(SearchButtonPressed(
                      searchPhrase: _searchFieldController.text));
                },
                color: Color(0xFF7FBCF1),
                child: Icon(
                  Icons.search,
                  size: 34,
                ),
                padding: EdgeInsets.all(4.0),
                shape: Border.all(width: 2.0, color: Color(0xFF7FBCF1)),
              ),
            )
          ],
        ),
        userList != null ? _buildUserList(userList) : SingleChildScrollView(),
      ],
    );
  }

  Widget _buildUserList(List<User> userList) {
    if (userList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          'No results found.',
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.grey[400],
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: userList.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildUser(userList[index]);
          },
        ),
      );
    }
  }

  Widget _buildUser(User user) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 0.01 * screenSize.height,
        left: 0.02 * screenSize.width,
        right: 0.02 * screenSize.width,
      ),
      child: Card(
        color: Color(0xFFDEDEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 21,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 0.01 * screenSize.height,
                  bottom: 0.01 * screenSize.height,
                  left: 0.04 * screenSize.width,
                ),
                child: Container(
                  height: 0.17 * screenSize.width,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2),
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/profile_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 42,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 0.03 * screenSize.width,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: Color(0xFF3D3A3A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${user.uniqueUsername}',
                      style: TextStyle(color: Color(0xAA3D3A3A), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 26,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 0.03 * screenSize.width,
                  right: 0.03 * screenSize.width,
                ),
                child: ButtonTheme(
                  height: 40,
                  child: FlatButton(
                    onPressed: () {
                      _eventInvitationBloc.add(InviteButtonPressed(
                          eventID: eventID, inviteeID: user.userID));
                    },
                    color: Color(0xFF7FBCF1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 32.0,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
