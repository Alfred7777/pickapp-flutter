import 'package:PickApp/repositories/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CreateEventState extends Equatable {
  const CreateEventState();

  @override
  List<Object> get props => [];
}

class CreateEventInitial extends CreateEventState {}

class CreateEventLoading extends CreateEventState {}

class CreateEventReady extends CreateEventState {
  final List<Discipline> disciplines;

  final LatLng pickedPos;

  const CreateEventReady({
    @required this.disciplines,
    @required this.pickedPos,
  });

  @override
  List<Object> get props => [disciplines, pickedPos];
}

class CreateEventCreated extends CreateEventState {
  final LatLng pos;
  final String message;

  const CreateEventCreated({
    @required this.pos,
    @required this.message,
  });

  @override
  List<Object> get props => [pos, message];
}

class CreateEventFailure extends CreateEventState {
  final List<Discipline> disciplines;
  final LatLng pickedPos;
  final String error;

  const CreateEventFailure({
    @required this.disciplines,
    @required this.pickedPos,
    @required this.error,
  });

  @override
  List<Object> get props => [disciplines, pickedPos, error];
}

class FetchDisciplinesFailure extends CreateEventState {
  final String error;

  const FetchDisciplinesFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
