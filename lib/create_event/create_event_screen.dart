import 'package:PickApp/map/map_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_event_map.dart';
import 'create_event_bloc.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class CreateEventScreen extends StatelessWidget {
  final EventRepository eventRepository;
  final MapBloc mapBloc;

  CreateEventScreen({
    Key key,
    @required this.eventRepository,
    @required this.mapBloc,
  })  : assert(eventRepository != null),
        assert(mapBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) {
        return CreateEventBloc(
          eventRepository: eventRepository,
          mapBloc: mapBloc,
        );
      },
      child: CreateEventMap(),
    ));
  }
}
