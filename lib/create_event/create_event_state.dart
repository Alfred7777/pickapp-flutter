import 'package:PickApp/repositories/eventRepository.dart';
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
  final List<EventPrivacyRule> eventPrivacySettings;
  final LatLng pickedPos;

  const CreateEventReady({
    @required this.disciplines,
    @required this.eventPrivacySettings,
    @required this.pickedPos,
  });

  @override
  List<Object> get props => [disciplines, eventPrivacySettings, pickedPos];
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
  final List<EventPrivacyRule> eventPrivacySettings;
  final LatLng pickedPos;
  final Map<String, dynamic> errors;

  const CreateEventFailure({
    @required this.disciplines,
    @required this.eventPrivacySettings,
    @required this.pickedPos,
    @required this.errors,
  });

  @override
  List<Object> get props => [disciplines, eventPrivacySettings, pickedPos, errors];
}

class FetchDisciplinesFailure extends CreateEventState {
  final String error;

  const FetchDisciplinesFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
