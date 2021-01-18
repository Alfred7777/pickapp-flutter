import 'package:PickApp/event_update/event_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'event_details_bloc.dart';
import 'event_details_event.dart';
import 'event_details_state.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'participation_request/participation_request_screen.dart';
import 'package:PickApp/event_invitation/event_invitation_screen.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';
import 'package:PickApp/widgets/list_bar/user_bar.dart';

class EventDetailsScrollable extends StatefulWidget {
  final String eventID;
  final bool showButtons;

  EventDetailsScrollable({
    @required this.eventID,
    @required this.showButtons,
  });

  @override
  State<EventDetailsScrollable> createState() => EventDetailsScrollableState(
        eventID: eventID,
        showButtons: showButtons,
      );
}

class EventDetailsScrollableState extends State<EventDetailsScrollable> {
  final String eventID;
  final bool showButtons;
  final eventRepository = EventRepository();
  EventDetailsBloc _eventDetailsBloc;

  EventDetailsScrollableState({
    @required this.eventID,
    @required this.showButtons,
  });

  @override
  void initState() {
    super.initState();
    _eventDetailsBloc = EventDetailsBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );
  }

  void _editEvent() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => EventUpdateScreen(
        eventID: eventID,
      ),
    );
    await Navigator.push(context, route);
    _eventDetailsBloc.add(FetchEventDetails(eventID));
  }

  void _inviteToEvent() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => EventInvitationScreen(eventID: eventID),
    );
    await Navigator.push(context, route);
    _eventDetailsBloc.add(FetchEventDetails(eventID));
  }

  void _manageEventAttendance(String request) {
    if (request == 'join') {
      _eventDetailsBloc.add(JoinEvent(eventID));
    } else if (request == 'leave') {
      _eventDetailsBloc.add(LeaveEvent(eventID));
    }
  }

  void _manageParticipationRequests() async {
    var route = MaterialPageRoute<void>(
      builder: (context) => ParticipationRequestScreen(
        eventID: eventID,
      ),
    );
    await Navigator.push(context, route);
    _eventDetailsBloc.add(FetchEventDetails(eventID));
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
            _eventDetailsBloc.add(FetchEventDetails(eventID));
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
            _eventDetailsBloc.add(FetchEventDetails(eventID));
          }
          if (state is EventDetailsReady) {
            return EventDetailsList(
              eventDetails: state.eventDetails,
              participantList: state.participantsList,
              manageParticipationRequests: _manageParticipationRequests,
              manageEventAttendance: _manageEventAttendance,
              editEvent: _editEvent,
              inviteToEvent: _inviteToEvent,
              showButtons: showButtons,
            );
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class EventDetailsList extends StatelessWidget {
  final EventDetails eventDetails;
  final List<User> participantList;
  final Function manageParticipationRequests;
  final Function manageEventAttendance;
  final Function editEvent;
  final Function inviteToEvent;
  final bool showButtons;

  const EventDetailsList({
    @required this.eventDetails,
    @required this.participantList,
    @required this.manageParticipationRequests,
    @required this.manageEventAttendance,
    @required this.editEvent,
    @required this.inviteToEvent,
    @required this.showButtons,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverMapHeader(
                minExtent: 0.14 * screenSize.height,
                maxExtent: 0.3 * screenSize.height,
                markerPos: eventDetails.position,
                privacyBadge: PrivacyBadge(
                  eventPrivacyRule: EventPrivacyRule.fromBooleans(
                    eventDetails.allowInvitations,
                    eventDetails.requireParticipationAcceptation,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      EventNameAndDate(
                        name: eventDetails.name,
                        startDate: eventDetails.startDate,
                        endDate: eventDetails.endDate,
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Divider(
                          color: Colors.grey[400],
                        ),
                      ),
                      EventButtons(
                        numberOfParticipants: participantList.length,
                        numberOfParticipationRequests: 10,
                        participationStatus: eventDetails.participationStatus,
                        isOrganiser: eventDetails.isOrganiser,
                        allowInvitations: eventDetails.allowInvitations,
                        requireParticipationAcceptation:
                            eventDetails.requireParticipationAcceptation,
                        manageParticipationRequests:
                            manageParticipationRequests,
                        manageEventAttendance: manageEventAttendance,
                        inviteToEvent: inviteToEvent,
                        showButtons: showButtons,
                      ),
                      EventDescription(
                        description: eventDetails.description,
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Divider(
                          color: Colors.grey[400],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                          ),
                          child: Text(
                            'Participants',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ParticipantList(
                        participantList: participantList,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: eventDetails.isOrganiser
          ? FloatingActionButton(
              elevation: 2,
              onPressed: editEvent,
              backgroundColor: Colors.blue[300],
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          : Container(),
    );
  }
}

class EventNameAndDate extends StatelessWidget {
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  const EventNameAndDate({
    @required this.name,
    @required this.startDate,
    @required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Event start:',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        EventDate(
          date: startDate,
          color: Colors.green,
        ),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Event end:',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        EventDate(
          date: endDate,
          color: Colors.redAccent,
        ),
      ],
    );
  }
}

class EventDate extends StatelessWidget {
  final DateTime date;
  final Color color;

  const EventDate({
    @required this.date,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(
              Icons.schedule,
              color: color,
              size: 16,
            ),
          ),
          Text(
            DateFormat.Hm().add_EEEE().format(date) +
                ', ' +
                DateFormat.MMMMd().format(date) +
                ', ' +
                DateFormat.y().format(date),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class EventButtons extends StatelessWidget {
  final int numberOfParticipants;
  final int numberOfParticipationRequests;
  final String participationStatus;
  final bool isOrganiser;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;
  final Function manageParticipationRequests;
  final Function manageEventAttendance;
  final Function inviteToEvent;
  final bool showButtons;

  const EventButtons({
    @required this.numberOfParticipants,
    @required this.numberOfParticipationRequests,
    @required this.participationStatus,
    @required this.isOrganiser,
    @required this.allowInvitations,
    @required this.requireParticipationAcceptation,
    @required this.manageParticipationRequests,
    @required this.manageEventAttendance,
    @required this.inviteToEvent,
    @required this.showButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EventParticipantsNumber(
          numberOfParticipants: numberOfParticipants,
          numberOfParticipationRequests: numberOfParticipationRequests,
          isOrganiser: isOrganiser,
          requireParticipationAcceptation: requireParticipationAcceptation,
          manageParticipationRequests: manageParticipationRequests,
        ),
        showButtons
            ? ButtonBar(
                mainAxisSize: MainAxisSize.max,
                alignment: MainAxisAlignment.spaceEvenly,
                buttonPadding: EdgeInsets.zero,
                children: [
                  EventRoundButton(
                    icon: Icons.add_alert,
                    label: 'Follow',
                    color: Colors.blue[300],
                    notifyParent: () {},
                  ),
                  EventMainButton(
                    text: participationStatus,
                    notifyParent: manageEventAttendance,
                  ),
                  EventRoundButton(
                    icon: Icons.person_add,
                    label: 'Invite',
                    color: isOrganiser ||
                            allowInvitations == true &&
                                participationStatus == 'joined'
                        ? Colors.blue[300]
                        : Colors.grey,
                    notifyParent: () {
                      if (isOrganiser) {
                        inviteToEvent();
                      } else if (participationStatus == 'joined' &&
                          allowInvitations) {
                        inviteToEvent();
                      }
                    },
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}

class EventParticipantsNumber extends StatelessWidget {
  final int numberOfParticipants;
  final int numberOfParticipationRequests;
  final bool isOrganiser;
  final bool requireParticipationAcceptation;
  final Function manageParticipationRequests;

  const EventParticipantsNumber({
    @required this.numberOfParticipants,
    @required this.numberOfParticipationRequests,
    @required this.isOrganiser,
    @required this.requireParticipationAcceptation,
    @required this.manageParticipationRequests,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isOrganiser && requireParticipationAcceptation
          ? manageParticipationRequests
          : () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numberOfParticipants.toString(),
            style: TextStyle(
              color: Color(0xFF3D3A3A),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: Stack(
              children: [
                Icon(
                  Icons.group,
                  color: Colors.black,
                  size: 40,
                ),
                Positioned(
                  right: 0,
                  child: isOrganiser && requireParticipationAcceptation
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
                            numberOfParticipationRequests.toString(),
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
    );
  }
}

class EventMainButton extends StatelessWidget {
  final String text;
  final Function notifyParent;

  const EventMainButton({
    @required this.text,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: MaterialButton(
        height: 40,
        minWidth: 128,
        onPressed: () {
          if (text == 'joined') {
            notifyParent('leave');
          }
          if (text == 'joinable') {
            notifyParent('join');
          }
        },
        color: text == 'joined'
            ? Colors.redAccent
            : text == 'requested'
                ? Colors.blue[900]
                : Colors.green,
        child: Text(
          text == 'joined'
              ? 'LEAVE'
              : text == 'requested'
                  ? 'REQUESTED'
                  : 'JOIN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class EventRoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Function notifyParent;

  const EventRoundButton({
    @required this.icon,
    @required this.label,
    @required this.color,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          height: 56,
          minWidth: 56,
          onPressed: notifyParent,
          color: color,
          child: Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
          shape: CircleBorder(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}

class EventDescription extends StatelessWidget {
  final String description;

  const EventDescription({
    @required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: 16,
            ),
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
              left: 16,
              right: 16,
              top: 2,
            ),
            child: Text(
              description ?? '',
              style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class ParticipantList extends StatelessWidget {
  final List<User> participantList;

  const ParticipantList({
    @required this.participantList,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (participantList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: participantList.length,
        itemBuilder: (BuildContext context, int index) {
          return UserBar(
            user: participantList[index],
            actionList: [],
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
                left: 20,
                right: 20,
                top: 16,
                bottom: 16,
              ),
              child: Text(
                'Nobody is participating in this event yet.',
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

class PrivacyBadge extends StatelessWidget {
  final EventPrivacyRule eventPrivacyRule;

  const PrivacyBadge({
    @required this.eventPrivacyRule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue[300].withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        eventPrivacyRule.name == 'Private'
            ? Icons.lock
            : eventPrivacyRule.name == 'Invite Only'
                ? Icons.person_add
                : Icons.public,
        size: 28,
        color: Colors.grey,
      ),
    );
  }
}
