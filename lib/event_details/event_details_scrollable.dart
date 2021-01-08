import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'event_details_bloc.dart';
import 'event_details_event.dart';
import 'event_details_state.dart';
import 'participation_request/participation_request_screen.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/event_invitation/event_invitation_screen.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventDetailsScrollable extends StatefulWidget {
  final String eventID;

  EventDetailsScrollable({@required this.eventID});

  @override
  State<EventDetailsScrollable> createState() =>
      EventDetailsScrollableState(eventID: eventID);
}

class EventDetailsScrollableState extends State<EventDetailsScrollable> {
  final String eventID;
  final eventRepository = EventRepository();
  EventDetailsBloc _eventDetailsBloc;

  EventDetailsScrollableState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _eventDetailsBloc = EventDetailsBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _eventDetailsBloc,
      listener: (context, state) {
        if (state is EventDetailsFailure) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildFailureAlert(context, state.error);
            },
          );
        }
      },
      child: BlocBuilder<EventDetailsBloc, EventDetailsState>(
        bloc: _eventDetailsBloc,
        condition: (prevState, currState) {
          if (currState is EventDetailsFailure) {
            return false;
          }
          if (currState is EventDetailsLoading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is EventDetailsUninitialized) {
            _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
          }
          if (state is EventDetailsUnjoined) {
            return _buildEventDetails(
              'joinable',
              state.eventDetails,
              state.participantsList,
            );
          }
          if (state is EventDetailsRequested) {
            return _buildEventDetails(
              'requested',
              state.eventDetails,
              state.participantsList,
            );
          }
          if (state is EventDetailsJoined) {
            return _buildEventDetails(
              'joined',
              state.eventDetails,
              state.participantsList,
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildFailureAlert(BuildContext context, String errorMessage) {
    return AlertDialog(
      title: Text('An Error Occured!'),
      content: Text(errorMessage),
      actions: [
        FlatButton(
          child: Text('Try Again'),
          onPressed: () {
            Navigator.of(context).pop();
            _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
          },
        ),
        FlatButton(
          child: Text('Go Back'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildEventParticipant(User participant) {
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
                      participant.name,
                      style: TextStyle(
                        color: Color(0xFF3D3A3A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${participant.uniqueUsername}',
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
                      var route = MaterialPageRoute<void>(
                        builder: (context) => ProfileScreen(
                          userID: participant.userID,
                        ),
                      );
                      Navigator.push(context, route);
                    },
                    color: Color(0xFF7FBCF1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Icon(
                      Icons.person,
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

  Widget _wrapIconWithCircle(Icon icon) {
    return Container(
      width: 34,
      height: 34,
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: icon,
    );
  }

  Widget _privacyBadge(EventPrivacyRule eventPrivacyRule) {
    switch (eventPrivacyRule.name) {
      case 'Private':
        {
          return _wrapIconWithCircle(
            Icon(
              Icons.lock,
              size: 24,
              color: Colors.grey,
            ),
          );
        }
        break;
      case 'Invite Only':
        {
          return _wrapIconWithCircle(
            Icon(
              Icons.group_add,
              size: 24,
              color: Colors.grey,
            ),
          );
        }
        break;
    }
    return _wrapIconWithCircle(
      Icon(
        Icons.public,
        size: 24,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildActionText(String joinedEventStringState) {
    var screenSize = MediaQuery.of(context).size;

    switch (joinedEventStringState) {
      case 'joined':
        {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
              Text(
                'LEAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }
        break;
      case 'requested':
        {
          return Text(
            'REQUESTED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        }
        break;
      case 'joinable':
        {
          return Text(
            'JOIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        }
        break;
    }
    // hack for handling missing return type error
    return Container();
  }

  Widget _buildActionFlatButton(String joinedEventStringState) {
    switch (joinedEventStringState) {
      case 'joined':
        {
          return FlatButton(
            onPressed: () {
              _eventDetailsBloc.add(
                LeaveEvent(eventID: eventID),
              );
            },
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: _buildActionText(joinedEventStringState),
          );
        }
        break;
      case 'requested':
        {
          return FlatButton(
            onPressed: () {},
            color: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: _buildActionText(joinedEventStringState),
          );
        }
        break;
      case 'joinable':
        {
          return FlatButton(
            onPressed: () {
              _eventDetailsBloc.add(
                JoinEvent(eventID: eventID),
              );
            },
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: _buildActionText(joinedEventStringState),
          );
        }
        break;
    }
    // hack for handling missing return type error
    return Container();
  }

  Widget _buildEventDetails(String joinedEventStringState,
      Map<String, dynamic> eventDetails, List<User> participantsList) {
    var screenSize = MediaQuery.of(context).size;

    bool allowInvitations = eventDetails['settings']['allow_invitations'];
    bool requireParticipationAcceptation =
        eventDetails['settings']['require_participation_acceptation'];

    var eventPrivacySetting = eventRepository.convertSettingsToEventPrivacyRule(
      allowInvitations,
      requireParticipationAcceptation,
    );

    var isOrganiser = eventDetails['participation']['is_organiser?'];

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.21 * screenSize.height,
            width: 0.20 * 1.4 * screenSize.height,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 0.025 * screenSize.height,
                    bottom: 0.025 * screenSize.width,
                  ),
                  child: Container(
                    height: 0.19 * screenSize.height,
                    width: 0.19 * 1.4 * screenSize.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/event_placeholder/${eventDetails['discipline_id']}.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0, //give the values according to your requirement
                  child: _privacyBadge(eventPrivacySetting),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.012 * screenSize.height),
            child: Text(
              eventDetails['name'],
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.005 * screenSize.height),
            child: Text(
              'Event start:',
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.005 * screenSize.height),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                Text(
                  DateFormat.Hm()
                          .add_EEEE()
                          .format(eventDetails['start_date']) +
                      ', ' +
                      DateFormat.MMMMd().format(eventDetails['start_date']) +
                      ', ' +
                      DateFormat.y().format(eventDetails['start_date']),
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.005 * screenSize.height),
            child: Text(
              'Event end:',
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.005 * screenSize.height),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 0.01 * screenSize.width),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
                Text(
                  DateFormat.Hm().add_EEEE().format(eventDetails['end_date']) +
                      ', ' +
                      DateFormat.MMMMd().format(eventDetails['end_date']) +
                      ', ' +
                      DateFormat.y().format(eventDetails['end_date']),
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0.006 * screenSize.height),
            child: Divider(
              color: Colors.black,
            ),
          ),
          InkWell(
            onTap: isOrganiser
                ? () async {
                    var route = MaterialPageRoute<void>(
                      builder: (context) => ParticipationRequestScreen(
                        eventID: eventID,
                      ),
                    );
                    await Navigator.push(context, route);
                    _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
                  }
                : () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  participantsList.length.toString(),
                  style: TextStyle(
                    color: Color(0xFF3D3A3A),
                    fontSize: 0.04 * screenSize.height,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 0.01 * screenSize.width,
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.group,
                        color: Colors.black,
                        size: 0.06 * screenSize.height,
                      ),
                      Positioned(
                        right: 0,
                        child: isOrganiser
                            ? Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 10,
                                  minHeight: 10,
                                ),
                                child: Text(
                                  '10',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  MaterialButton(
                    onPressed: () {},
                    color: Color(0xFF7FBCF1),
                    child: Icon(
                      Icons.add_alert,
                      size: 34,
                    ),
                    padding: EdgeInsets.all(8),
                    shape: CircleBorder(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 1.0, bottom: 6.0),
                    child: Text(
                      'Follow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
              ButtonTheme(
                height: 40,
                minWidth: 0.34 * screenSize.width,
                child: _buildActionFlatButton(joinedEventStringState),
              ),
              Column(
                children: [
                  MaterialButton(
                    onPressed: joinedEventStringState == 'joined' &&
                                allowInvitations == true ||
                            isOrganiser
                        ? () {
                            var route = MaterialPageRoute<void>(
                              builder: (context) =>
                                  EventInvitationScreen(eventID: eventID),
                            );
                            Navigator.push(context, route);
                          }
                        : () {},
                    color: joinedEventStringState == 'joined' &&
                                allowInvitations == true ||
                            isOrganiser
                        ? Color(0xFF7FBCF1)
                        : Colors.grey,
                    child: Icon(
                      Icons.person_add,
                      size: 34,
                    ),
                    padding: EdgeInsets.all(8),
                    shape: CircleBorder(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 1.0, bottom: 6.0),
                    child: Text(
                      'Invite',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 0.06 * screenSize.width),
              child: Text(
                'About',
                style: TextStyle(
                  color: Color(0xFF3D3A3A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 0.06 * screenSize.width,
                right: 0.06 * screenSize.width,
                top: 0.005 * screenSize.height,
              ),
              child: Text(
                eventDetails['description'] ?? '',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0.006 * screenSize.height),
            child: Divider(
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 0.06 * screenSize.width,
                bottom: 0.005 * screenSize.height,
              ),
              child: Text(
                'Participants',
                style: TextStyle(
                  color: Color(0xFF3D3A3A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: participantsList.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildEventParticipant(participantsList[index]);
            },
          ),
        ],
      ),
    );
  }
}
