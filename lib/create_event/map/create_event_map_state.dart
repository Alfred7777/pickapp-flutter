import 'package:PickApp/repositories/map_repository.dart';
import 'package:fluster/fluster.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class CreateEventMapState extends Equatable {
  const CreateEventMapState();

  @override
  List<Object> get props => [];
}

class CreateEventMapInitial extends CreateEventMapState {}

class CreateEventMapLoading extends CreateEventMapState {}

class CreateEventMapReady extends CreateEventMapState {
  final List<MapMarker> locations;
  final Fluster<MapMarker> locationFluster;

  const CreateEventMapReady({
    @required this.locations,
    @required this.locationFluster,
  });

  @override
  List<Object> get props => [
        locations,
        locationFluster,
      ];
}

class CreateEventMapCreated extends CreateEventMapState {
  final String message;
  final LatLng position;

  const CreateEventMapCreated({
    @required this.message,
    @required this.position,
  });

  @override
  List<Object> get props => [message, position];
}

class FetchLocationsFailure extends CreateEventMapState {
  final String error;

  const FetchLocationsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
