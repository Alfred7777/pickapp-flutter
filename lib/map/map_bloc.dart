import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PickApp/repositories/map_repository.dart';
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
        var _eventMarkers = await mapRepository.getEventMap();
        var _eventFluster = initEventFluster(_eventMarkers);
        var _locationMarkers = await mapRepository.getLocationMap();
        var _locationFluster = initLocationFluster(_locationMarkers);

        yield MapReady(
          eventMarkers: _eventMarkers,
          eventFluster: _eventFluster,
          locationMarkers: _locationMarkers,
          locationFluster: _locationFluster,
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
        var _locationMarkers = await mapRepository.getLocationMap();
        var _locationFluster = initLocationFluster(_locationMarkers);

        yield MapReady(
          eventMarkers: _filteredEventMarkers,
          eventFluster: _eventFluster,
          locationMarkers: _locationMarkers,
          locationFluster: _locationFluster,
        );
      } catch (exception) {
        yield FetchMapFailure(error: exception.message);
      }
    }
  }

  Fluster<EventMarker> initEventFluster(List<EventMarker> events) {
    return Fluster<EventMarker>(
      minZoom: 0,
      maxZoom: 20,
      radius: 48,
      extent: 256,
      nodeSize: 64,
      points: events,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          EventMarker(
        id: UniqueKey().toString(),
        position: LatLng(lat, lng),
        disciplineID: null,
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }
  Fluster<LocationMarker> initLocationFluster(List<LocationMarker> locations) {
    return Fluster<LocationMarker>(
      minZoom: 0,
      maxZoom: 20,
      radius: 48,
      extent: 256,
      nodeSize: 64,
      points: locations,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          LocationMarker(
        id: UniqueKey().toString(),
        position: LatLng(lat, lng),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }
}
