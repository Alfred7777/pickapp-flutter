import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event_details_scrollable.dart';
import 'event_details_event.dart';
import 'event_details_bloc.dart';
import 'event_details_state.dart';

import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/event_update/ui/first_step/first_step_screen.dart';
import 'package:PickApp/repositories/event_repository.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventID;

  EventDetailsScreen({@required this.eventID});

  @override
  State<EventDetailsScreen> createState() =>
      EventDetailsScreenState(eventID: eventID);
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  final String eventID;
  final eventRepository = EventRepository();
  EventDetailsBloc _eventDetailsBloc;

  EventDetailsScreenState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _eventDetailsBloc = EventDetailsBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );
    _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailsBloc, EventDetailsState>(
        bloc: _eventDetailsBloc,
        builder: (context, state) {
          // a bit hacky but i din't figured better way to do it(fast)
          if (state is EventDetailsJoined) {
            return _buildScrollable(eventID, state.isOrganiser);
          } else if (state is EventDetailsUnjoined) {
            return _buildScrollable(eventID, state.isOrganiser);
          } else {
            return _buildScrollable(eventID, false);
          }
        });
  }

  Widget _buildScrollable(String eventID, bool isOrganiser) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: EventDetailsScrollable(eventID: eventID),
      ),
      floatingActionButton: isOrganiser
          ? FloatingActionButton(
              elevation: 5,
              onPressed: () {
                var route = MaterialPageRoute<void>(
                  builder: (context) => FirstStepScreen(eventID: eventID),
                );
                Navigator.push(context, route);
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.edit,
                color: Color(0xFF7FBCF1),
              ),
            )
          : Container(),
    );
  }
}
