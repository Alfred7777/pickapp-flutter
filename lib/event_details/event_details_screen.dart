import 'package:PickApp/event_update/ui/first_step/first_step_screen.dart';
import 'package:flutter/material.dart';
import 'event_details_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventID;

  EventDetailsScreen({@required this.eventID});

  @override
  State<EventDetailsScreen> createState() =>
      EventDetailsScreenState(eventID: eventID);
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  final String eventID;

  EventDetailsScreenState({@required this.eventID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: EventDetailsScrollable(eventID: eventID),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
