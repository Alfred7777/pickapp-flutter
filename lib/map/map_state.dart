import 'package:PickApp/repositories/eventRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapUninitialized extends MapState {}

class MapReady extends MapState {
  final Set<Location> locations;

  const MapReady({@required this.locations});

  @override
  List<Object> get props => [locations];
}
