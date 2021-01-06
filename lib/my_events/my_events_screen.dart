import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_events_bloc.dart';
import 'my_events_state.dart';
import 'my_events_event.dart';
import 'package:PickApp/widgets/event_location_screen.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/event_details/event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  MyEventsScreen();

  @override
  State<MyEventsScreen> createState() => MyEventsScreenState();
}

class MyEventsScreenState extends State<MyEventsScreen> {
  final eventRepository = EventRepository();
  MyEventsBloc _myEventsBloc;

  @override
  void initState() {
    super.initState();
    _myEventsBloc = MyEventsBloc(eventRepository: eventRepository);
  }

  @override
  void dispose() {
    super.dispose();
    _myEventsBloc.close();
  }

  void answerInvitation(EventInvitation eventInvitation, String answer) {
    if (answer == 'Accept') {
      _myEventsBloc.add(
        AnswerInvitation(
          invitation: eventInvitation,
          myActiveEvents: _myEventsBloc.state.props[0],
          myPastEvents: _myEventsBloc.state.props[1],
          eventInvitations: _myEventsBloc.state.props[2],
          answer: 'accept',
        ),
      );
    } else {
      _myEventsBloc.add(
        AnswerInvitation(
          invitation: eventInvitation,
          myActiveEvents: _myEventsBloc.state.props[0],
          myPastEvents: _myEventsBloc.state.props[1],
          eventInvitations: _myEventsBloc.state.props[2],
          answer: 'reject',
        ),
      );
    }
    Navigator.pop(context);
    _myEventsBloc.add(FetchMyEvents());
  }

  Future<void> _refreshView() async {
    _myEventsBloc.add(FetchMyEvents());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyEventsBloc, MyEventsState>(
      bloc: _myEventsBloc,
      listener: (context, state) {
        if (state is FetchEventsFailure) {
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
      child: BlocBuilder<MyEventsBloc, MyEventsState>(
        bloc: _myEventsBloc,
        condition: (prevState, currState) {
          if (currState is AnswerInvitationFailure) {
            return false;
          }
          if (prevState is MyEventsReady || currState is MyEventsLoading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is MyEventsUninitialized) {
            _myEventsBloc.add(FetchMyEvents());
          }
          if (state is MyEventsReady) {
            return _buildMyEvents(
              state.myActiveEvents,
              state.myPastEvents,
              state.eventInvitations,
            );
          }
          return LoadingScreen();
        },
      ),
    );
  }

  Widget _buildMyEvents(
      Map<DateTime, List<Event>> myActiveEvents,
      Map<DateTime, List<Event>> myPastEvents,
      List<EventInvitation> eventInvitations) {
    var screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: mainScreenTopBar(context),
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
                      text: 'Current Events',
                      icon: Icon(
                        Icons.event_note,
                      ),
                      iconMargin: EdgeInsets.zero,
                    ),
                    Tab(
                      text: 'Past Events',
                      icon: Icon(
                        Icons.history,
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
                      onRefresh: _refreshView,
                      child: ActiveEventsList(
                        events: myActiveEvents,
                        eventInvitations: eventInvitations,
                        notifyParent: answerInvitation,
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: _refreshView,
                      child: PastEventsList(
                        events: myPastEvents,
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

class ActiveEventsList extends StatelessWidget {
  final Map<DateTime, List<Event>> events;
  final List<EventInvitation> eventInvitations;
  final Function notifyParent;

  const ActiveEventsList({
    @required this.events,
    @required this.eventInvitations,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          eventInvitations.isNotEmpty
              ? Container(
                  height: 0.1 * screenSize.width,
                  width: screenSize.width,
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    border: Border(
                      bottom: BorderSide(color: Colors.black45, width: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.05 * screenSize.width),
                        child: Text(
                          'Event Invitations',
                          style: TextStyle(
                            color: Color(0xFF3D3A3A),
                            fontSize: 0.05 * screenSize.width,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: eventInvitations.length,
            itemBuilder: (BuildContext context, int index) {
              return InvitationBar(
                eventInvitation: eventInvitations[index],
                notifyParent: notifyParent,
              );
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              var date = events.keys.elementAt(index);
              return EventDayList(
                date: date,
                events: events[date],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PastEventsList extends StatelessWidget {
  final Map<DateTime, List<Event>> events;

  const PastEventsList({
    @required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        var date = events.keys.elementAt(index);
        return EventDayList(
          date: date,
          events: events[date],
        );
      },
    );
  }
}

class EventDayList extends StatelessWidget {
  final DateTime date;
  final List<Event> events;

  const EventDayList({
    @required this.date,
    @required this.events,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: 0.1 * screenSize.width,
          width: screenSize.width,
          decoration: BoxDecoration(
            color: Color(0xFFF3F3F3),
            border: Border(
              bottom: BorderSide(color: Colors.black45, width: 0.3),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0.05 * screenSize.width),
                child: Text(
                  DateFormat.EEEE().add_MMMd().format(date),
                  style: TextStyle(
                    color: Color(0xFF3D3A3A),
                    fontSize: 0.05 * screenSize.width,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return EventBar(event: events[index]);
          },
        ),
      ],
    );
  }
}

class EventBar extends StatelessWidget {
  final Event event;

  const EventBar({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        var route = MaterialPageRoute<void>(
          builder: (context) => EventDetailsScreen(eventID: event.id),
        );
        Navigator.push(context, route);
      },
      child: Container(
        height: 0.16 * screenSize.width,
        width: screenSize.width,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black45, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0.05 * screenSize.width),
              child: Container(
                height: 0.1 * screenSize.width,
                width: 0.1 * screenSize.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/event_icon/${event.disciplineID}.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 0.04 * screenSize.width),
                child: Text(
                  event.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Color(0xFF3D3A3A),
                    fontSize: 0.05 * screenSize.width,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              height: 0.12 * screenSize.width,
              width: 0.17 * screenSize.width,
              child: MaterialButton(
                onPressed: () {
                  var route = MaterialPageRoute<void>(
                    builder: (context) => EventLocationScreen(event: event),
                  );
                  Navigator.push(context, route);
                },
                color: Color(0xFF7FBCF1),
                child: Icon(
                  Icons.place,
                  size: 24,
                ),
                shape: CircleBorder(),
              ),
            ),
            Container(
              height: 0.17 * screenSize.width,
              width: 0.25 * screenSize.width,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black45, width: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  DateFormat.jm().format(event.startDate),
                  style: TextStyle(
                    color: Color(0xFFA7A7A7),
                    fontSize: 0.05 * screenSize.width,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvitationBar extends StatelessWidget {
  final EventInvitation eventInvitation;
  final Function notifyParent;

  const InvitationBar({
    @required this.eventInvitation,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return InvitationDialog(
              eventInvitation: eventInvitation,
              notifyParent: notifyParent,
            );
          },
        );
      },
      child: Container(
        height: 0.16 * screenSize.width,
        width: screenSize.width,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black45, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0.05 * screenSize.width),
              child: Container(
                height: 0.1 * screenSize.width,
                width: 0.1 * screenSize.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/event_icon/${eventInvitation.eventDetails['discipline_id']}.png',
                    ),
                    fit: BoxFit.cover,
                  ),
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
                      eventInvitation.eventDetails['name'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Color(0xFF3D3A3A),
                        fontSize: 0.048 * screenSize.width,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${eventInvitation.inviter.uniqueUsername} has invited you',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFFA7A7A7),
                        fontSize: 0.03 * screenSize.width,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvitationDialog extends StatelessWidget {
  final EventInvitation eventInvitation;
  final Function notifyParent;

  const InvitationDialog({
    @required this.eventInvitation,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: 0.21 * screenSize.height,
        bottom: 0.055 * screenSize.height,
        left: 0.05 * screenSize.width,
        right: 0.05 * screenSize.width,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.02 * screenSize.width),
        child: Material(
          color: Colors.grey[100],
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverMapHeader(
                      minExtent: 0.14 * screenSize.height,
                      maxExtent: 0.30 * screenSize.height,
                      markerPos: eventInvitation.eventDetails['event_pos'],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        InvitationDetails(eventInvitation: eventInvitation),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 0.12 * screenSize.height,
                  width: 0.9 * screenSize.width,
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InvitationButton(
                        eventInvitation: eventInvitation,
                        text: 'Accept',
                        color: Colors.green,
                        notifyParent: notifyParent,
                      ),
                      InvitationButton(
                        eventInvitation: eventInvitation,
                        text: 'Reject',
                        color: Colors.red,
                        notifyParent: notifyParent,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InvitationDetails extends StatelessWidget {
  final EventInvitation eventInvitation;

  const InvitationDetails({
    @required this.eventInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 0.012 * screenSize.height,
          ),
          child: Text(
            eventInvitation.eventDetails['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[850],
              fontSize: 0.072 * screenSize.width,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0.016 * screenSize.height,
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Text(
              'Start date',
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.03 * screenSize.width,
          ),
          child: Divider(
            color: Colors.grey[500],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Row(
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
                          .format(eventInvitation.eventDetails['start_date']) +
                      ', ' +
                      DateFormat.MMMMd()
                          .format(eventInvitation.eventDetails['start_date']) +
                      ', ' +
                      DateFormat.y()
                          .format(eventInvitation.eventDetails['start_date']),
                  style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0.02 * screenSize.height,
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.03 * screenSize.width,
          ),
          child: Divider(
            color: Colors.grey[500],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 0.05 * screenSize.width,
              right: 0.03 * screenSize.width,
            ),
            child: Text(
              eventInvitation.eventDetails['description'],
              style: TextStyle(
                color: Color(0xFF3D3A3A),
                fontSize: 15,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 0.14 * screenSize.height,
        ),
      ],
    );
  }
}

class InvitationButton extends StatelessWidget {
  final EventInvitation eventInvitation;
  final String text;
  final Color color;
  final Function notifyParent;

  const InvitationButton({
    @required this.eventInvitation,
    @required this.text,
    @required this.color,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return MaterialButton(
      height: 0.06 * screenSize.height,
      onPressed: () => notifyParent(eventInvitation, text),
      color: color,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 0.024 * screenSize.height,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          0.02 * screenSize.width,
        ),
      ),
    );
  }
}
