import 'package:flutter/material.dart';
import 'event_details_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventID;

  EventDetailsScreen({@required this.eventID});

  @override
  State<EventDetailsScreen> createState() => EventDetailsScreenState(
        eventID: eventID,
      );
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  final String eventID;

  EventDetailsScreenState({@required this.eventID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: EventDetailsScrollable(
          eventID: eventID,
        ),
      ),
    );
  }
}
