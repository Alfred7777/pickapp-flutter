import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_events_bloc.dart';
import 'my_events_state.dart';
import 'my_events_event.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/list_bar/event_bar.dart';
import 'package:PickApp/widgets/list_bar/invitation_bar.dart';
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
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: refreshView,
                      child: EventList(
                        events: pastEvents,
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
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: eventInvitations.length,
      itemBuilder: (BuildContext context, int index) {
        return InvitationBar(
          eventInvitation: eventInvitations[index],
          answerInvitation: answerInvitation,
        );
      },
    );
  }
}

class EventList extends StatelessWidget {
  final List<Event> events;

  const EventList({
    @required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        return EventBar(
          event: events[index],
        );
      },
    );
  }
}
