import 'package:PickApp/repositories/mapRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:fluster/fluster.dart';
import 'package:meta/meta.dart';

class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapUninitialized extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final List<EventMarker> eventMarkers;
  final Fluster<EventMarker> eventFluster;

  const MapReady({
    @required this.eventMarkers,
    @required this.eventFluster,
  });

  @override
  List<Object> get props => [eventMarkers, eventFluster];
}

class FetchMapFailure extends MapState {
  final String error;

  const FetchMapFailure({
    @required this.error,
  });

  @override
  List<Object> get props => [error];
}
