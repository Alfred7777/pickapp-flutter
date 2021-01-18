import 'package:flutter/material.dart';
import 'event_details_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventID;
  final bool showButtons;

  EventDetailsScreen({
    @required this.eventID,
    @required this.showButtons,
  });

  @override
  State<EventDetailsScreen> createState() => EventDetailsScreenState(
        eventID: eventID,
        showButtons: showButtons,
      );
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  final String eventID;
  final bool showButtons;

  EventDetailsScreenState({
    @required this.eventID,
    @required this.showButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: SafeArea(
        child: EventDetailsScrollable(
          eventID: eventID,
          showButtons: showButtons,
        ),
      ),
    );
  }
}
