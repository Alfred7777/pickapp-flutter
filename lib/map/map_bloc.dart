import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventRepository eventRepository;

  MapBloc({@required this.eventRepository}) : assert(eventRepository != null);

  @override
  MapState get initialState => MapUninitialized();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is FetchLocations) {
      var locations = await eventRepository.getMap();
      var disciplines = await eventRepository.getDisciplines();
      var icons = <String, BitmapDescriptor>{};

      for (var discipline in disciplines) {
        var icon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(28, 28), devicePixelRatio: 2.5),
            'assets/images/${discipline.id}.png');
        icons.addAll({discipline.id: icon});
      }

      yield MapReady(locations: locations, icons: icons);
      return;
    }
  }
}
