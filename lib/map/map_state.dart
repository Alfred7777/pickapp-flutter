import 'package:PickApp/repositories/eventRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter_platform_interface/src/types/bitmap.dart';
import 'package:meta/meta.dart';

class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapUninitialized extends MapState {}

class MapReady extends MapState {
  final Set<Location> locations;
  final Map<String, BitmapDescriptor> icons;

  const MapReady({@required this.locations, @required this.icons});

  @override
  List<Object> get props => [locations];
}
