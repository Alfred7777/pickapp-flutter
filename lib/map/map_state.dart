import 'package:PickApp/repositories/map_repository.dart';
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
  final List<MapMarker> markers;
  final Fluster<MapMarker> fluster;

  const MapReady({
    @required this.markers,
    @required this.fluster,
  });

  @override
  List<Object> get props => [
        markers,
        fluster,
      ];
}

class FetchMapFailure extends MapState {
  final String error;

  const FetchMapFailure({
    @required this.error,
  });

  @override
  List<Object> get props => [error];
}
