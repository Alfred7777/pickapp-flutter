import 'package:PickApp/repositories/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CreateLocationState extends Equatable {
  const CreateLocationState();

  @override
  List<Object> get props => [];
}

class CreateLocationInitial extends CreateLocationState {}

class CreateLocationLoading extends CreateLocationState {}

class CreateLocationReady extends CreateLocationState {
  final List<Discipline> disciplines;
  final LatLng pickedPos;

  const CreateLocationReady({
    @required this.disciplines,
    @required this.pickedPos,
  });

  @override
  List<Object> get props => [disciplines, pickedPos];
}

class CreateLocationCreated extends CreateLocationState {
  final LatLng pos;
  final String message;

  const CreateLocationCreated({
    @required this.pos,
    @required this.message,
  });

  @override
  List<Object> get props => [pos, message];
}

class CreateLocationFailure extends CreateLocationState {
  final List<Discipline> disciplines;
  final LatLng pickedPos;
  final String error;

  const CreateLocationFailure({
    @required this.disciplines,
    @required this.pickedPos,
    @required this.error,
  });

  @override
  List<Object> get props => [disciplines, pickedPos, error];
}

class FetchDisciplinesFailure extends CreateLocationState {
  final String error;

  const FetchDisciplinesFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
