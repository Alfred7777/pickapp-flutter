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
    var _disciplines = await eventRepository.getDisciplines();
    var _icons = await assignIconsToDisciplines(_disciplines);

    if (event is FetchLocations) {
      var locations = await eventRepository.getMap();

      yield MapReady(locations: locations, icons: _icons);
      return;
    }
    if (event is FilterMapByDiscipline) {
      var filteredLocations = await eventRepository.filterMapByDiscipline(event.disciplineId);

      yield MapReady(locations: filteredLocations, icons: _icons);
      return;
    }
  }

  Future<Map<String, BitmapDescriptor>> assignIconsToDisciplines(
      List<Discipline> disciplines) async {
    var icons = <String, BitmapDescriptor>{};

    for (var discipline in disciplines) {
      var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/marker/${discipline.id}.png',
      );
      icons.addAll({discipline.id: icon});
    }

    return icons;
  }
}
