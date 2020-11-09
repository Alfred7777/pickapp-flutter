import 'package:PickApp/event_details/event_details_bloc.dart';
import 'package:PickApp/event_details/event_details_event.dart';
import 'package:PickApp/event_details/event_details_state.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
        builder: (context, state) {
          if (state is EventDetailsUninitialized) {
            _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
          }
          if (state is EventDetailsUnjoined) {
            return _buildEventDetails(
                false, state.eventDetails, state.participantsList);
          }
          if (state is EventDetailsJoined) {
            return _buildEventDetails(
                true, state.eventDetails, state.participantsList);
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
            _eventDetailsBloc.add(EventDetailsFetchFailure(eventID: eventID));
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

  Widget _buildEventDetails(bool joinedEvent, Map<String, dynamic> eventDetails,
      List<User> participantsList) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.025 * screenSize.height),
            child: Container(
              height: 0.19 * screenSize.height,
              width: 0.19 * 1.4 * screenSize.height,
              decoration: BoxDecoration(
                border: Border.all(width: 0.4),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/event_placeholder/${eventDetails['discipline_id']}.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                child: Icon(
                  Icons.group,
                  color: Colors.black,
                  size: 0.06 * screenSize.height,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonTheme(
                height: 40,
                minWidth: 0.34 * screenSize.width,
                child: FlatButton(
                  onPressed: joinedEvent
                      ? () {}
                      : () {
                          _eventDetailsBloc.add(
                            JoinEvent(eventID: eventID),
                          );
                        },
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: joinedEvent
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 0.01 * screenSize.width),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
                            Text(
                              'JOINED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'JOIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
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
