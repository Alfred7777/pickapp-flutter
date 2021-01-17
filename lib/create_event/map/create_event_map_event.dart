import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateEventMapEvent extends Equatable {
  const CreateEventMapEvent();

  @override
  List<Object> get props => [];
}

class FetchLocations extends CreateEventMapEvent {}

class EventCreated extends CreateEventMapEvent {
  final String message;
  final LatLng position;

  const EventCreated({
    @required this.message,
    @required this.position,
  });

  @override
  List<Object> get props => [message, position];
}
