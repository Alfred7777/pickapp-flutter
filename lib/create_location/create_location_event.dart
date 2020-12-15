import 'package:PickApp/repositories/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateLocationEvent extends Equatable {
  const CreateLocationEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends CreateLocationEvent {}

class LocationPicked extends CreateLocationEvent {
  final List<Discipline> disciplines;
  final LatLng pickedPos;

  const LocationPicked({
    @required this.disciplines,
    @required this.pickedPos,
  });

  @override
  List<Object> get props => [disciplines, pickedPos];
}

class CreateLocationButtonPressed extends CreateLocationEvent {
  final List<Discipline> disciplines;

  final String locationName;
  final String locationDescription;
  final List<String> locationDisciplineIDs;
  final LatLng locationPos;

  const CreateLocationButtonPressed({
    @required this.disciplines,
    @required this.locationName,
    @required this.locationDescription,
    @required this.locationDisciplineIDs,
    @required this.locationPos,
  });

  @override
  List<Object> get props => [
        disciplines,
        locationName,
        locationDescription,
        locationDisciplineIDs,
        locationPos,
      ];
}
