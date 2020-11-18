import 'package:PickApp/event_update/bloc/event_update_bloc.dart';
import 'package:PickApp/event_update/ui/second_step/second_step_scrollable.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/top_bar.dart';

class SecondStepScreen extends StatelessWidget {
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;

  SecondStepScreen({
    @required this.eventID,
    @required this.eventUpdateBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editEventScreenTopBar(context),
      body: SafeArea(
        child: SecondStepScrollable(
          eventID: eventID,
          eventUpdateBloc: eventUpdateBloc,
        ),
      ),
    );
  }
}
