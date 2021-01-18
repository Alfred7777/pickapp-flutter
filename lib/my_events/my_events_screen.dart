import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_events_bloc.dart';
import 'my_events_state.dart';
import 'my_events_event.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/list_bar/event_bar.dart';
import 'package:PickApp/widgets/list_bar/event_invitation_bar.dart';
import 'package:PickApp/repositories/event_repository.dart';

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
    _myEventsBloc.close();
    super.dispose();
  }

  void _answerInvitation(EventInvitation eventInvitation, String answer) {
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
            return MyEvents(
              activeEvents: state.myActiveEvents,
              pastEvents: state.myPastEvents,
              eventInvitations: state.eventInvitations,
              refreshView: _refreshView,
              answerInvitation: _answerInvitation,
            );
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class MyEvents extends StatelessWidget {
  final List<Event> activeEvents;
  final List<Event> pastEvents;
  final List<EventInvitation> eventInvitations;
  final Function refreshView;
  final Function answerInvitation;

  const MyEvents({
    @required this.activeEvents,
    @required this.pastEvents,
    @required this.eventInvitations,
    @required this.refreshView,
    @required this.answerInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
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
                      text: 'Invites',
                      icon: Icon(
                        Icons.mail_outline,
                      ),
                      iconMargin: EdgeInsets.zero,
                    ),
                    Tab(
                      text: 'Active Events',
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
                      onRefresh: refreshView,
                      child: EventInvitationList(
                        eventInvitations: eventInvitations,
                        answerInvitation: answerInvitation,
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: refreshView,
                      child: EventList(
                        events: activeEvents,
                        refreshView: refreshView,
                        isPast: false,
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: refreshView,
                      child: EventList(
                        events: pastEvents,
                        refreshView: refreshView,
                        isPast: true,
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

class EventInvitationList extends StatelessWidget {
  final List<EventInvitation> eventInvitations;
  final Function answerInvitation;

  const EventInvitationList({
    @required this.eventInvitations,
    @required this.answerInvitation,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (eventInvitations.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: eventInvitations.length,
        itemBuilder: (BuildContext context, int index) {
          return EventInvitationBar(
            eventInvitation: eventInvitations[index],
            actionList: [
              MaterialButton(
                onPressed: () => answerInvitation(
                  eventInvitations[index],
                  'Accept',
                ),
                elevation: 0,
                height: 42,
                minWidth: 42,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              MaterialButton(
                onPressed: () => answerInvitation(
                  eventInvitations[index],
                  'Reject',
                ),
                elevation: 0,
                height: 42,
                minWidth: 42,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.transparent,
                shape: CircleBorder(),
                child: Icon(
                  Icons.clear,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return ListView(
        children: [
          Container(
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
                    'You don\'t have any pending invitations.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}

class EventList extends StatelessWidget {
  final List<Event> events;
  final Function refreshView;
  final bool isPast;

  const EventList({
    @required this.events,
    @required this.refreshView,
    @required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (events.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          return EventBar(
            event: events[index],
            refreshView: refreshView,
          );
        },
      );
    } else {
      return ListView(
        children: [
          Container(
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
                    isPast
                        ? 'You don\'t have any events that you participated in.'
                        : 'You don\'t have any upcoming events.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
