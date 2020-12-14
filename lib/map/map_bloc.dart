import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PickApp/repositories/mapRepository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository mapRepository;

  MapBloc({@required this.mapRepository}) : assert(mapRepository != null);

  @override
  MapState get initialState => MapUninitialized();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is FetchLocations) {
      yield MapLoading();
      try {
        var _eventMarkers = await mapRepository.getEventMap();
        var _eventFluster = initEventFluster(_eventMarkers);
        yield MapReady(
          eventMarkers: _eventMarkers,
          eventFluster: _eventFluster,
        );
      } catch (exception) {
        yield FetchMapFailure(error: exception.message);
      }
    }
    if (event is FilterMapByDiscipline) {
      yield MapLoading();
      try {
        var _filteredEventMarkers = await mapRepository.getEventMap(
          event.disciplineId,
        );
        var _eventFluster = initEventFluster(_filteredEventMarkers);
        yield MapReady(
          eventMarkers: _filteredEventMarkers,
          eventFluster: _eventFluster,
        );
      } catch (exception) {
        yield FetchMapFailure(error: exception.message);
      }
    }
  }

  Fluster<EventMarker> initEventFluster(List<EventMarker> locations) {
    return Fluster<EventMarker>(
      minZoom: 0,
      maxZoom: 20,
      radius: 200,
      extent: 2048,
      nodeSize: 64,
      points: locations,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          EventMarker(
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        disciplineID: null,
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }
}
