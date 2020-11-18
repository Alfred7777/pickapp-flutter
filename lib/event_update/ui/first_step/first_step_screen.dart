import 'package:PickApp/event_update/ui/first_step/first_step_scrollable.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';

class FirstStepScreen extends StatelessWidget {
  final String eventID;

  FirstStepScreen({@required this.eventID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editEventScreenTopBar(context),
      body: SafeArea(
        child: FirstStepScrollable(eventID: eventID),
      ),
    );
  }
}
