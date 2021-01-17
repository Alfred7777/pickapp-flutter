import 'package:PickApp/repositories/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CreateEventFormState extends Equatable {
  const CreateEventFormState();

  @override
  List<Object> get props => [];
}

class CreateEventFormInitial extends CreateEventFormState {}

class CreateEventFormLoading extends CreateEventFormState {}

class CreateEventFormReady extends CreateEventFormState {
  final List<Discipline> disciplines;

  const CreateEventFormReady({
    @required this.disciplines,
  });

  @override
  List<Object> get props => [disciplines];
}

class CreateEventFormCreated extends CreateEventFormState {
  final LatLng pos;
  final String message;

  const CreateEventFormCreated({
    @required this.pos,
    @required this.message,
  });

  @override
  List<Object> get props => [pos, message];
}

class CreateEventFormFailure extends CreateEventFormState {
  final String error;

  const CreateEventFormFailure({
    @required this.error,
  });

  @override
  List<Object> get props => [error];
}

class FetchDisciplinesFailure extends CreateEventFormState {
  final String error;

  const FetchDisciplinesFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
