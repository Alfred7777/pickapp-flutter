import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:PickApp/utils/marker_clusters.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository mapRepository;

  MapBloc({@required this.mapRepository}) : assert(mapRepository != null);

  @override
  MapState get initialState => MapUninitialized();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is FetchMap) {
      yield MapLoading();
      try {
        var _markers = await mapRepository.getMap();
        var _fluster = MarkerClusters.initFluster(_markers);

        yield MapReady(
          markers: _markers,
          fluster: _fluster,
          activeFilters: <String, dynamic>{
            'discipline_ids': <String>[],
            'filter_by_date': false,
            'from_date': null,
            'to_date': null,
            'visibility': 'events_and_locations',
          },
        );
      } catch (exception) {
        yield FetchMapFailure(error: exception.message);
      }
    }
    if (event is FilterMap) {
      yield MapLoading();
      try {
        var _filteredMarkers = await mapRepository.getMap(
          disciplineIDs: event.disciplineIDs,
          fromDate: event.fromDate,
          toDate: event.toDate,
          visibility: event.visibility,
        );

        var _fluster = MarkerClusters.initFluster(_filteredMarkers);

        yield MapReady(
          markers: _filteredMarkers,
          fluster: _fluster,
          activeFilters: <String, dynamic>{
            'discipline_ids': event.disciplineIDs,
            'filter_by_date': event.filterByDate,
            'from_date': event.fromDate,
            'to_date': event.toDate,
            'visibility': event.visibility,
          },
        );
      } catch (exception) {
        yield FetchMapFailure(error: exception.message);
      }
    }
  }
}
