import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_event_map.dart';
import 'create_event_bloc.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class CreateEventPage extends StatelessWidget {
  final EventRepository eventRepository;

  CreateEventPage({Key key, @required this.eventRepository}): assert(eventRepository != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return CreateEventBloc(
            eventRepository: eventRepository
          );
        },
        child: CreateEventMap(),
      )
    );
  }
}
